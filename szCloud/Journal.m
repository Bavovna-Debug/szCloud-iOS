//
//  szCloud
//
//  Copyright (c) 2014 Meine Werke. All rights reserved.
//

#import "Journal.h"

@interface Journal ()

@property (strong, nonatomic, readwrite) NSMutableArray *records;

@end

@implementation Journal

@synthesize records = _records;

+ (Journal *)sharedJournal
{
    static dispatch_once_t onceToken;
    static Journal *journal;

    dispatch_once(&onceToken, ^{
        journal = [[Journal alloc] init];
    });

    return journal;
}

- (id)init
{
    self = [super init];
    if (self == nil)
        return nil;

    self.records = [NSMutableArray array];

    return self;
}

@end
