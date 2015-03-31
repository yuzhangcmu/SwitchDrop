//
//  Obstacle.m
//  flyingHouse2
//
//  Created by ZHANG YU on 3/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Obstacle.h"

@implementation Obstacle {
    CCNode *_bigBalloon;
}

- (void)didLoadFromCCB {
    _bigBalloon.physicsBody.collisionType = @"level";
    
    //This means that the collisions will be detected by your objects and you can have access to them via callbacks, but they will not actually interact.
    //_bigBalloon.physicsBody.sensor = TRUE;
}


- (void)setupRandomPosition {
    
}

@end
