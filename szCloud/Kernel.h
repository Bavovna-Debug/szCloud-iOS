//
//  szCloud
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IPChangeNotifier.h"

#undef SCREENSHOTING

@protocol KernelDelegate;

@interface Kernel : NSObject <IPChangeNotifierDelegate>

typedef enum {
    KernelStatusCommunicatingNimbus,
    KernelStatusError,
    KernelStatusInitializing,
    KernelStatusOK
} KernelStatus;

@property (nonatomic, strong, readwrite) id<KernelDelegate> delegate;

@property (assign, nonatomic) KernelStatus      status;
@property (strong, nonatomic) NSDate            *statusStamp;
@property (strong, nonatomic) NSString          *dnsName;
@property (strong, nonatomic) NSString          *userName;
@property (strong, nonatomic) NSString          *password;

+ (Kernel *)sharedKernel;

- (id)init;

- (void)storeSettingsWithDnsName:(NSString *)dnsName
                        userName:(NSString *)userName
                        psssword:(NSString *)password;

- (void)fire;

- (void)setStatus:(KernelStatus)status;

- (void)tellNimbus;

@end

@protocol KernelDelegate <NSObject>

@optional

-(void)statusDidChange:(Kernel *)kernel;

@end