//
//  szCloud
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "SettingsEditSubview.h"

@implementation SettingsEditSubview

- (void)awakeFromNib
{
    [super awakeFromNib];

    for (UIView *subview in self.subviews)
    {
        if (subview.tag == 1) {
            [self prepareInputViewLayout:subview];
        } else if (subview.tag == 2) {
            [self prepareDescriptionLayout:(UILabel *)subview];
        }
    }
    CGRect rect = self.frame;
    NSLog(@"SUB = %f %f %f %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

- (void)prepareInputViewLayout:(UIView *)inputView
{
    //[inputView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    //[inputView.layer setBorderWidth:1.0f];
}

- (void)prepareDescriptionLayout:(UILabel *)description
{
    CGSize textSize = [description.text sizeWithFont:description.font
                                   constrainedToSize:CGSizeMake(CGRectGetWidth(description.frame), CGFLOAT_MAX)
                                       lineBreakMode:NSLineBreakByWordWrapping];

    CGRect viewBounds = [self bounds];
    viewBounds.size.height += ceil(textSize.height) - CGRectGetHeight(description.bounds);
    [self setBounds:viewBounds];
}

@end
