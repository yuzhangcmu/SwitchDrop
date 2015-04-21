//
//  MyManager.h
//  flyingHouse2
//
//  Created by ZHANG YU on 4/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <foundation/Foundation.h>

@interface MyManager : NSObject {
    NSString *SScore;
}

@property (nonatomic, retain) NSString *SScore;

+ (id)sharedManager;

@end
