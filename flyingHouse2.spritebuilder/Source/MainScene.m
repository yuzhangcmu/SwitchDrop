#import "MainScene.h"

// Support the motion control.

#import "MainScene.h"
#import "Obstacle.h"

#import "CoreMotion/CoreMotion.h"

@import SpriteKit;

#define ARC4RANDOM_MAX      0x100000000

CCButton *_restartButton;

static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 160.f;

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrdeHero
};

@implementation MainScene {
    CCSprite *_hero;
    CCNode *_walls;
    
    
    CCPhysicsNode *_pyhNode;
    
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_ground3;
    
    NSArray *_grounds;
    
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    CGFloat _scrollSpeed;
    
    CMMotionManager *_motionManager;
    
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
}

//Next, extend the collision handling method to show this restart button:
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
    NSLog(@"Game Over");
    [self gameOver];

    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
//    [goal removeFromParent];
//    _points++;
//    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    return TRUE;
}

- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

#pragma The_accelerometer

// Create the board of the screen.
- (void) createSceneContents
{
    
}


- (id) init {
    if (self = [super init])
    {
        _motionManager = [[CMMotionManager alloc] init];
        
        // Create the board of the screen.
        //self.window.rootViewController.view.backgroundColor = [SKColor blackColor];
//        self.view.scaleMode = SKSceneScaleModeAspectFit;
  //      self.view.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    }
    return self;
}



- (void)onEnter
{
    [super onEnter];
    [_motionManager startAccelerometerUpdates];
}

- (void)onExit
{
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
}
#pragma <#arguments#>


- (void)didLoadFromCCB {
    _grounds = @[_ground1, _ground2, _ground3];
    self.userInteractionEnabled = TRUE;
    
    // set this class as delegate
    _pyhNode.collisionDelegate = self;
    // set collision txpe
    
    _hero.physicsBody.collisionType = @"hero";
    _hero.zOrder = DrawingOrdeHero;
    
    _obstacles = [NSMutableArray array];
    
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
    // Init the speed.
    _scrollSpeed = 80.f;
}

- (void) addScoreByOne {
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
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
    
    // 70: the lowest place.
    CGFloat range = 400 - 70;
    
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 200+ (random * range));
    
    [_pyhNode addChild:obstacle];
    [_obstacles addObject:obstacle];
    
    NSLog(@"the position of obstacle: %f", obstacle.position.x);
    //[self addScoreByOne];
    
    // value between 0.f and 1.f
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_gameOver) {
//        [_hero.physicsBody applyImpulse:ccp(0, 400.f)];
//        [_hero.physicsBody applyAngularImpulse:10000.f];
//        _sinceTouch = 0.f;
        
        [_hero.physicsBody applyImpulse:ccp(0, 400.f)];
        
        // clamp velocity
        float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
        _hero.physicsBody.velocity = ccp(0, yVelocity);
    }
    
    
}

- (void)gameOver {
    if (!_gameOver) {
        _scrollSpeed = 0.f;
        _gameOver = TRUE;
        _restartButton.visible = TRUE;
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        
        [_hero stopAllActions];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
        
        // Stop the Accelerometer.
        [_motionManager stopAccelerometerUpdates];
    }
}

- (void)update:(CCTime)delta {
    _hero.position = ccp(_hero.position.x + delta * _scrollSpeed, _hero.position.y);
    
    //_walls.position = ccp(_walls.position.x + delta * _scrollSpeed, _walls.position.y);
    
    // Use this to detect the movement of the house.
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    //CGFloat newXPosition = _hero.position.x + acceleration.x * 1000 * delta;
    CGFloat newXPosition = _hero.position.x + acceleration.x * 500 * delta;
    
    // Limit the value to be from 0 to self.contentSize.width
    //newXPosition = clampf(newXPosition, 0, self.contentSize.width);
    
    _hero.position = CGPointMake(newXPosition, _hero.position.y);
    //    _label.position = CGPointMake(newXPosition, _label.position.y);
    
    _pyhNode.position = ccp(_pyhNode.position.x - delta * _scrollSpeed, _pyhNode.position.y);
    
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
            
            [self addScoreByOne];            
        }
    }    

    [self spawnNewObstacle];
    
    
}

@end