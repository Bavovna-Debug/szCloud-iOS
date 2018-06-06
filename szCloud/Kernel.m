//
//  szCloud
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "Kernel.h"

@interface Kernel () <CLLocationManagerDelegate>

@property (strong, nonatomic) IPChangeNotifier   *ipChecker;
@property (strong, nonatomic) CLLocationManager  *locationManager;

@end

#define VersionKey          @"Version"
#define DnsNameKey          @"DnsName"
#define UserNameKey         @"UserName"
#define PasswordKey         @"Password"

#define ScreenshotDnsName   @"ipad.apple.capillatus.net"
#define ScreenshotUserName  @"apple"
#define ScreenshotPassword  @"2w3xWMoANuGoc4a2"

@implementation Kernel

@synthesize status = _status;

+ (Kernel *)sharedKernel
{
    static dispatch_once_t onceToken;
    static Kernel *kernel;

    dispatch_once(&onceToken, ^{
        kernel = [[Kernel alloc] init];
    });

    return kernel;
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;

#ifdef SCREENSHOTING
    [self setDnsName:ScreenshotDnsName];
    [self setUserName:ScreenshotUserName];
    [self setPassword:ScreenshotPassword];
#else
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [self setDnsName:[defaults valueForKey:DnsNameKey]];
    [self setUserName:[defaults valueForKey:UserNameKey]];
    [self setPassword:[defaults valueForKey:PasswordKey]];
#endif

    self.ipChecker = [[IPChangeNotifier alloc] init];
    [self.ipChecker setDelegate:self];

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager setHeadingFilter:2.0f];
    [self.locationManager setDelegate:self];

    [self setStatus:KernelStatusInitializing];

    return self;
}

- (void)storeSettingsWithDnsName:(NSString *)dnsName
                        userName:(NSString *)userName
                        psssword:(NSString *)password
{
#ifndef SCREENSHOTING
    [self setDnsName:dnsName];
    [self setUserName:userName];
    [self setPassword:password];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *version = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [defaults setValue:version forKey:VersionKey];

    [defaults setValue:dnsName forKey:DnsNameKey];
    [defaults setValue:userName forKey:UserNameKey];
    [defaults setValue:password forKey:PasswordKey];
#endif

    [self tellNimbus];
}

- (void)fire
{
    [self.ipChecker fire];
}

- (void)setStatus:(KernelStatus)status
{
    if (_status != status) {
        _status = status;

        [self setStatusStamp:[NSDate date]];

        if (self.delegate != nil)
            [self.delegate statusDidChange:self];
    }
}

#ifdef DEBUG

- (void)wlanIPv4DidChangeFrom:(NSString *)oldIP
                           to:(NSString *)newIP
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
        [self pushNotification];
    }

    NSLog(@"WLAN IPv4 %@ -> %@", oldIP, newIP);
}

- (void)wlanIPv6DidChangeFrom:(NSString *)oldIP
                           to:(NSString *)newIP
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
        [self pushNotification];
    }

    NSLog(@"WLAN IPv6 %@ -> %@", oldIP, newIP);
}

- (void)cellIPv4DidChangeFrom:(NSString *)oldIP
                           to:(NSString *)newIP
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
        [self pushNotification];
    }

    NSLog(@"Cell IPv4 %@ -> %@", oldIP, newIP);
}

- (void)cellIPv6DidChangeFrom:(NSString *)oldIP
                           to:(NSString *)newIP
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
        [self pushNotification];
    }

    NSLog(@"Cell IPv6 %@ -> %@", oldIP, newIP);
}

#endif

- (void)ipDidChange
{
    /*
     if ([self.ipChecker hasWlanIPv4] == YES) {
     [self tellNimbus:[self.ipChecker wlanIPv4]];
     } else if ([self.ipChecker hasCellIPv4] == YES) {
     [self tellNimbus:[self.ipChecker cellIPv4]];
     } else {
     [self tellNimbus:NO_IPv4];
     }

     if ([self.ipChecker hasWlanIPv6] == YES) {
     [self tellNimbus:[self.ipChecker wlanIPv6]];
     } else if ([self.ipChecker hasCellIPv6] == YES) {
     [self tellNimbus:[self.ipChecker cellIPv6]];
     } else {
     [self tellNimbus:NO_IPv6];
     }
     */
    [self performSelector:@selector(tellNimbus)];
}

- (void)tellNimbus
{
    NSString            *serverName;
    NSString            *parameters;
    NSURL               *url;
    NSMutableURLRequest *serviceRequest;
    NSHTTPURLResponse   *response;
    NSError             *error;
    NSData              *responseData;

    [self setStatus:KernelStatusCommunicatingNimbus];

    serverName = [NSString stringWithFormat:@"nimbus.szcloud.de"];
    parameters = [NSString stringWithFormat:@"username=%@&password=%@&domain=%@",
                  [[self userName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                  [[self password] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],
                  [[self dnsName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];

    url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/dyndns?%@", serverName, parameters]];
    serviceRequest = [NSMutableURLRequest requestWithURL:url];
    [serviceRequest setValue:@"text" forHTTPHeaderField:@"Content-type"];
    [serviceRequest setHTTPMethod:@"GET"];

    responseData = [NSURLConnection sendSynchronousRequest:serviceRequest
                                         returningResponse:&response
                                                     error:&error];
    if (!responseData) {
        [self setStatus:KernelStatusError];
        [self alertNoResponseFromNimbus];
    } else {
        if ([response statusCode] == 500) {
            [self setStatus:KernelStatusError];
            [self alertError500];
        } else {
            /*NSString *strdata = [[NSString alloc]initWithData:responseData
             encoding:NSUTF8StringEncoding];*/
            [self setStatus:KernelStatusOK];
        }
    }
}

- (void)pushNotification
{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil)
        return;
    localNotif.fireDate = [NSDate date];
    localNotif.timeZone = [NSTimeZone defaultTimeZone];

    localNotif.alertBody = [NSString stringWithFormat:@"IP address changed minutes."];
    localNotif.alertAction = NSLocalizedString(@"View Details", nil);

    //localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = 1;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

#pragma mark CLLocationManagerDelegate delegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    [self fire];
}

#pragma mark Alerts

- (void)alertNoResponseFromNimbus
{
    NSString *title;
    NSString *message;
    NSString *cancelButton;
    UIAlertView *alertView;

    title = NSLocalizedStringFromTable(@"ALERT_TITLE_ERROR", @"Alerts", nil);
    message = NSLocalizedStringFromTable(@"ALERT_NIMBUS_ERROR_500", @"Alerts", nil);
    cancelButton = NSLocalizedStringFromTable(@"ALERT_BUTTON_OK", @"Alerts", nil);

    alertView = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:cancelButton
                                 otherButtonTitles:nil];

    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

- (void)alertError500
{
    NSString *title;
    NSString *message;
    NSString *cancelButton;
    UIAlertView *alertView;

    title = NSLocalizedStringFromTable(@"ALERT_TITLE_ERROR", @"Alerts", nil);
    message = NSLocalizedStringFromTable(@"ALERT_NIMBUS_ERROR_500", @"Alerts", nil);
    cancelButton = NSLocalizedStringFromTable(@"ALERT_BUTTON_OK", @"Alerts", nil);

    alertView = [[UIAlertView alloc] initWithTitle:title
                                           message:message
                                          delegate:self
                                 cancelButtonTitle:cancelButton
                                 otherButtonTitles:nil];

    [alertView setAlertViewStyle:UIAlertViewStyleDefault];
    [alertView show];
}

@end
