//
//  szCloud
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Journal : NSObject

@property (strong, nonatomic, readonly) NSMutableArray *records;

+ (Journal *)sharedJournal;

@end
