#import "MainScene.h"

#import "MainScene.h"



#define ARC4RANDOM_MAX      0x100000000

static const CGFloat scrollSpeed = 80.f;
static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 160.f;

// visibility on a 3,5-inch iPhone ends a 88 points and we want some meat
static const CGFloat minimumYPositionTopPipe = 128.f;
// visibility ends at 480 and we want some meat
static const CGFloat maximumYPositionBottomPipe = 440.f;
// distance between top and bottom pipe
static const CGFloat pipeDistance = 142.f;
// calculate the end of the range of top pipe
static const CGFloat maximumYPositionTopPipe = maximumYPositionBottomPipe - pipeDistance;

@implementation MainScene {
    CCSprite *_hero;
    CCPhysicsNode *_pyhNode;
    
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_ground3;
    
    NSArray *_grounds;
    
    NSMutableArray *_obstacles;
}

- (void)didLoadFromCCB {
    _grounds = @[_ground1, _ground2, _ground3];
    self.userInteractionEnabled = TRUE;
    
    _obstacles = [NSMutableArray array];
    
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
}

- (void)spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    CCNode *obstacle = [CCBReader load:@"obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    CGFloat range = 400 - 0;
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, (random * range));
    [_pyhNode addChild:obstacle];
    [_obstacles addObject:obstacle];
    
    // value between 0.f and 1.f
    

}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    [_hero.physicsBody applyImpulse:ccp(0, 400.f)];
    
    // clamp velocity
    float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _hero.physicsBody.velocity = ccp(0, yVelocity);
}

- (void)update:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + delta * scrollSpeed, _hero.position.y);
    _pyhNode.position = ccp(_pyhNode.position.x - delta * scrollSpeed, _pyhNode.position.y);
    
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_pyhNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        //NSLog(@"ground.position: %f, The groundWorldPosition: %f, groundScreenPosition: %f", ground.position.x, groundWorldPosition.x, groundScreenPosition.x);
        
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 3 * ground.contentSize.width, ground.position.y);
            
            //NSLog(@"ground.position: %f, The groundWorldPosition: %f, groundScreenPosition: %f", ground.position.x, groundWorldPosition.x, groundScreenPosition.x);
            
        }
    }    

    [self spawnNewObstacle];
}


@end