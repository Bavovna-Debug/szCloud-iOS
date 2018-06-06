//
//  szCloud
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IPChangeNotifierInterval    1.0f
#define ForceNimbusMinimumInterval  300.0f

#define NO_IPv4  @"0.0.0.0"
#define NO_IPv6  @"0.0.0.0"

@protocol IPChangeNotifierDelegate;

@interface IPChangeNotifier : NSObject

@property (weak,   nonatomic, readwrite) id<IPChangeNotifierDelegate> delegate;

@property (strong, nonatomic, readonly) NSString *wlanIPv4;
@property (strong, nonatomic, readonly) NSString *wlanIPv6;
@property (strong, nonatomic, readonly) NSString *cellIPv4;
@property (strong, nonatomic, readonly) NSString *cellIPv6;

- (void)fire;

- (Boolean)hasWlanIPv4;

- (Boolean)hasWlanIPv6;

- (Boolean)hasCellIPv4;

- (Boolean)hasCellIPv6;

@end

@protocol IPChangeNotifierDelegate <NSObject>

@optional

- (void)wlanIPv4DidChangeFrom:(NSString *)oldIP
                           to:(NSString *)newIP;

- (void)wlanIPv6DidChangeFrom:(NSString *)oldIP
                           to:(NSString *)newIP;

- (void)cellIPv4DidChangeFrom:(NSString *)oldIP
                           to:(NSString *)newIP;

- (void)cellIPv6DidChangeFrom:(NSString *)oldIP
                           to:(NSString *)newIP;

@required

- (void)ipDidChange;

@end
