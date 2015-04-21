//
//  Plane.m
//  flyingHouse2
//
//  Created by ZHANG YU on 4/21/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Plane.h"

@implementation Plane {
    CCNode *_plane;
    CCNode *_awardBomb;
}

- (void)didLoadFromCCB {
    //_bigBalloon.physicsBody.collisionType = @"level";
    
    _awardBomb.physicsBody.collisionType = @"awardBomb";
    
    //This means that the collisions will be detected by your objects and you can have access to them via callbacks, but they will not actually interact.
    //_plane.physicsBody.sensor = TRUE;
    _awardBomb.physicsBody.sensor = TRUE;
}


- (void)setupRandomPosition {
    
}


@end
