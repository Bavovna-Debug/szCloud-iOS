//
//  szCloud
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "ApplicationDelegate.h"
#import "Journal.h"
#import "Kernel.h"

@interface ApplicationDelegate ()

//@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@end

@implementation ApplicationDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];

    if (systemVersion >= 7.0f) {
        [application setMinimumBackgroundFetchInterval:MinimumBackgroundFetchInterval];
    }

    if (systemVersion >= 8.0f) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeAlert;

        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:types
                                                                                             categories:nil];
        [application registerUserNotificationSettings:notificationSettings];
    }

    [Journal sharedJournal];

    [Kernel sharedKernel];
    
    [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application { }

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
    self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
    }];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        [self backgroundEngine];
    });
    */
}

- (void)applicationWillEnterForeground:(UIApplication *)application { }

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[Kernel sharedKernel] fire];
}

- (void)applicationWillTerminate:(UIApplication *)application { }

- (void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"Background fetch");

    [[Kernel sharedKernel] fire];

    completionHandler(UIBackgroundFetchResultNewData);
}

@end
