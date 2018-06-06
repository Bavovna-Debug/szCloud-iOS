//
//  szCloud
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Journal.h"
#import "IPChangeNotifier.h"

#import <ifaddrs.h>
#import <arpa/inet.h>

@interface IPChangeNotifier ()

@property (strong, nonatomic, readwrite) NSString  *wlanIPv4;
@property (strong, nonatomic, readwrite) NSString  *wlanIPv6;
@property (strong, nonatomic, readwrite) NSString  *cellIPv4;
@property (strong, nonatomic, readwrite) NSString  *cellIPv6;

@property (strong, nonatomic)            NSTimer   *timer;

@property (strong, nonatomic)            NSDate    *lastChange;

@end

@implementation IPChangeNotifier

@synthesize delegate = _delegate;
@synthesize wlanIPv4 = _wlanIPv4;
@synthesize wlanIPv6 = _wlanIPv6;
@synthesize cellIPv4 = _cellIPv4;
@synthesize cellIPv6 = _cellIPv6;

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;

    self.wlanIPv4 = @"";
    self.wlanIPv6 = @"";
    self.cellIPv4 = @"";
    self.cellIPv6 = @"";

    self.timer = [NSTimer scheduledTimerWithTimeInterval:IPChangeNotifierInterval
                                                  target:self
                                                selector:@selector(heartbeatCheckIP)
                                                userInfo:nil
                                                 repeats:YES];
    return self;
}

- (void)fire
{
    [self.timer fire];
}

- (Boolean)hasWlanIPv4
{
    return ([self.wlanIPv4 isEqualToString:@""] == NO);
}

- (Boolean)hasWlanIPv6
{
    return ([self.wlanIPv6 isEqualToString:@""] == NO);
}

- (Boolean)hasCellIPv4
{
    return ([self.cellIPv4 isEqualToString:@""] == NO);
}

- (Boolean)hasCellIPv6
{
    return ([self.cellIPv6 isEqualToString:@""] == NO);
}

- (void)heartbeatCheckIP
{
    NSLog(@"Hearthbeat");

    NSString *currentWlanIPv4 = @"";
    NSString *currentWlanIPv6 = @"";
    NSString *currentCellIPv4 = @"";
    NSString *currentCellIPv6 = @"";

    struct ifaddrs *interfaces = NULL;
    if (getifaddrs(&interfaces) == 0)
    {
        for (struct ifaddrs *addr = interfaces; addr != NULL; addr = addr->ifa_next)
        {
            sa_family_t  family;
            NSString     *interfaceName;
            NSString     *ipAddress;

            family = addr->ifa_addr->sa_family;

            interfaceName = [NSString stringWithUTF8String:addr->ifa_name];

            ipAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)addr->ifa_addr)->sin_addr)];

            if ([interfaceName isEqualToString:@"en0"]) {
                if (family == AF_INET) {
                    currentWlanIPv4 = ipAddress;
                } else if (family == AF_INET6) {
                    currentWlanIPv6 = ipAddress;
                }
            } else if ([interfaceName isEqualToString:@"pdp_ip0"]) {
                if (family == AF_INET) {
                    currentCellIPv4 = ipAddress;
                } else if (family == AF_INET6) {
                    currentCellIPv6 = ipAddress;
                }
            }
        }

        freeifaddrs(interfaces);
    }

    Boolean somethingChanged = NO;

    if ([currentWlanIPv4 isEqualToString:self.wlanIPv4] == NO)
    {
        if (self.delegate != nil)
            if ([self.delegate respondsToSelector:@selector(wlanIPv4DidChangeFrom:to:)])
                [self.delegate wlanIPv4DidChangeFrom:self.wlanIPv4 to:currentWlanIPv4];

        self.wlanIPv4 = currentWlanIPv4;

        somethingChanged = YES;
    }

    if ([currentWlanIPv6 isEqualToString:self.wlanIPv6] == NO)
    {
        if (self.delegate != nil)
            if ([self.delegate respondsToSelector:@selector(wlanIPv6DidChangeFrom:to:)])
                [self.delegate wlanIPv6DidChangeFrom:self.wlanIPv6 to:currentWlanIPv6];

        self.wlanIPv6 = currentWlanIPv6;

        somethingChanged = YES;
    }

    if ([currentCellIPv4 isEqualToString:self.cellIPv4] == NO)
    {
        if (self.delegate != nil)
            if ([self.delegate respondsToSelector:@selector(cellIPv4DidChangeFrom:to:)])
                [self.delegate cellIPv4DidChangeFrom:self.cellIPv4 to:currentCellIPv4];

        self.cellIPv4 = currentCellIPv4;

        somethingChanged = YES;
    }

    if ([currentCellIPv6 isEqualToString:self.cellIPv6] == NO)
    {
        if (self.delegate != nil)
            if ([self.delegate respondsToSelector:@selector(cellIPv6DidChangeFrom:to:)])
                [self.delegate cellIPv6DidChangeFrom:self.cellIPv6 to:currentCellIPv6];

        self.cellIPv6 = currentCellIPv6;

        somethingChanged = YES;
    }

    if (somethingChanged == YES)
    {
        if (self.delegate != nil)
        {
            [self.delegate ipDidChange];
            self.lastChange = [NSDate date];
        }
    } else {
        if (self.lastChange == nil)
        {
            if (self.delegate != nil)
            {
                [self.delegate ipDidChange];
                self.lastChange = [NSDate date];
            }
        } else {
            NSDate *now = [NSDate date];
            NSTimeInterval sinceLastChange = [now timeIntervalSinceDate:self.lastChange];

            if (sinceLastChange > ForceNimbusMinimumInterval)
            {
                if (self.delegate != nil)
                {
                    [self.delegate ipDidChange];

                    self.lastChange = [NSDate date];
                }
            }
        }
    }
}

@end