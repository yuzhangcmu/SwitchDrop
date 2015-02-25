//
//  Seal.m
//  PeevedPenguins
//
//  Created by ZHANG YU on 2/10/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"seal";
}

@end
