//
//  MyManager.m
//  flyingHouse2
//
//  Created by ZHANG YU on 4/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "MyManager.h"

static MyManager *sharedMyManager = nil;

@implementation MyManager

@synthesize SScore;

#pragma mark Singleton Methods
+ (id)sharedManager {
    @synchronized(self) {
        if(sharedMyManager == nil)
        sharedMyManager = [[super allocWithZone:NULL] init];
    }
    return sharedMyManager;
}
//+ (id)allocWithZone:(NSZone *)zone {
//    return [[self sharedManager] retain];
//}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

//- (id)retain {
//    return self;
//}

- (id)init {
    if (self == [super init]) {
        //this is the default for your score
        SScore = @"0";
    }
    return self;
}


@end