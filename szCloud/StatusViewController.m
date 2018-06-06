//
//  szCloud
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Kernel.h"
#import "StatusViewController.h"

@interface StatusViewController () <KernelDelegate>

@property (weak, nonatomic) IBOutlet UIView *statusPanelView;
@property (weak, nonatomic) IBOutlet UIImageView *redLightOff;
@property (weak, nonatomic) IBOutlet UIImageView *redLightOn;
@property (weak, nonatomic) IBOutlet UIImageView *yellowLightOff;
@property (weak, nonatomic) IBOutlet UIImageView *yellowLightOn;
@property (weak, nonatomic) IBOutlet UIImageView *greenLightOff;
@property (weak, nonatomic) IBOutlet UIImageView *greenLightOn;

@end

@implementation StatusViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.statusPanelView.layer setBorderWidth:0.5f];
    [self.statusPanelView.layer setBorderColor:[[UIColor darkGrayColor] CGColor]];
    [self.statusPanelView.layer setCornerRadius:4.0f];

    Kernel *kernel = [Kernel sharedKernel];

    [kernel setDelegate:self];

    [self switchLights:[kernel status]];
}

- (void)switchLights:(KernelStatus)kernelStatus
{
    switch (kernelStatus)
    {
        case KernelStatusCommunicatingNimbus:
            [self.redLightOff     setHidden:NO];
            [self.redLightOn      setHidden:YES];
            [self.yellowLightOff  setHidden:YES];
            [self.yellowLightOn   setHidden:NO];
            [self.greenLightOff   setHidden:NO];
            [self.greenLightOn    setHidden:YES];
            break;

        case KernelStatusError:
            [self.redLightOff     setHidden:YES];
            [self.redLightOn      setHidden:NO];
            [self.yellowLightOff  setHidden:NO];
            [self.yellowLightOn   setHidden:YES];
            [self.greenLightOff   setHidden:NO];
            [self.greenLightOn    setHidden:YES];
            break;

        case KernelStatusInitializing:
            [self.redLightOff     setHidden:YES];
            [self.redLightOn      setHidden:NO];
            [self.yellowLightOff  setHidden:YES];
            [self.yellowLightOn   setHidden:NO];
            [self.greenLightOff   setHidden:NO];
            [self.greenLightOn    setHidden:YES];
            break;

        case KernelStatusOK:
            [self.redLightOff     setHidden:NO];
            [self.redLightOn      setHidden:YES];
            [self.yellowLightOff  setHidden:NO];
            [self.yellowLightOn   setHidden:YES];
            [self.greenLightOff   setHidden:YES];
            [self.greenLightOn    setHidden:NO];
            break;
    }
}

#pragma mark Kernel delegate

- (void)statusDidChange:(Kernel *)kernel
{
    [self switchLights:[kernel status]];
}

@end
