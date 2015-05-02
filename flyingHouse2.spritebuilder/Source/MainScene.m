#import "MainScene.h"

// Support the motion control.

#import "MainScene.h"
#import "Obstacle.h"

#import "MyManager.h"

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
    
    CCPhysicsNode *_pyhNode;
    
    CCNode *_ground1;
    CCNode *_ground2;
    CCNode *_ground3;
    
    NSArray *_grounds;
    
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    CCButton *_bombButton;
    
    BOOL _gameOver;
    CGFloat _scrollSpeed;
    
    CMMotionManager *_motionManager;
    
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
    
    // Record the number of the bombs.
    NSInteger _bombNum;
    CCLabelTTF *_bombNumLabel;
    
    CGFloat _screenLeftBoard;
}

// Next, extend the collision handling method to show this restart button:
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
//    NSLog(@"Game Over");
    [self gameOver];
    return TRUE;
}

// The hero hit the goal. Add the score.
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero coin:(CCNode *)coin {
    // load particle effect
    CCParticleSystem *getCoin = (CCParticleSystem *)[CCBReader load:@"getCoin"];
    // make the particle effect clean itself up, once it is completed
    getCoin.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    getCoin.position = coin.position;
    
    // add the particle effect to the same node the seal is on
    [_pyhNode addChild:getCoin];
    
    [coin removeFromParent];
    
    // Add 10 score if hit a coin.
    [self addScore: 10];
    return TRUE;
}

// The hero hit the reward of bomb, increase the bomb.
-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero awardBomb:(CCNode *)awardBomb {
    // load particle effect
    CCParticleSystem *getBomb = (CCParticleSystem *)[CCBReader load:@"getCoin"];
    // make the particle effect clean itself up, once it is completed
    getBomb.autoRemoveOnFinish = TRUE;
    // getBomb the particle effect on the seals position
    getBomb.position = awardBomb.position;
    
    // add the particle effect to the same node the seal is on
    [_pyhNode addChild:getBomb];
    
    [awardBomb removeFromParent];
    
    // Add 100 score if hit a coin.
    [self addScore: 10];    
    
    _bombNum++;
    [self refreshBombLabel];
    
    return TRUE;
}

- (void) refreshBombLabel {
    _bombNumLabel.string = [NSString stringWithFormat:@"%ld", (long)_bombNum];
}


- (void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (void)fireBomb {
    if (_bombNum > 0) {
        // The bomb number should be reduce by 1.
        _bombNum--;
        [self refreshBombLabel];
        
        //CCNode *previousObstacle = [_obstacles lastObject];
        //[previousObstacle removeFromParent];
        
        //[_pyhNode removeChild:previousObstacle];
        
        
        // load particle effect
        CCParticleSystem *bomb = (CCParticleSystem *)[CCBReader load:@"bombExplosion"];
        // make the particle effect clean itself up, once it is completed
        bomb.autoRemoveOnFinish = TRUE;
        // place the particle effect on the seals position
        bomb.position = _hero.position;
        
        // add the particle effect to the same node the seal is on
        [_pyhNode addChild:bomb];

        
        for (CCNode *object in _obstacles) {
            
            // load particle effect
            CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"obstacleExplosion"];
            // make the particle effect clean itself up, once it is completed
            explosion.autoRemoveOnFinish = TRUE;
            // place the particle effect on the seals position
            explosion.position = object.position;
            
            // add the particle effect to the same node the seal is on
            [object.parent addChild:explosion];
            
            // finally, remove the destroyed object
            [object removeFromParent];            
        }
        
        [_obstacles removeAllObjects];
    }
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
    
    // set collision type
    
    _hero.physicsBody.collisionType = @"hero";
    _hero.zOrder = DrawingOrdeHero;
    
    _obstacles = [NSMutableArray array];
    
    // Create 4 obstacles.
    [self creaeInitObstacles];
    
    // Init the speed.
    _scrollSpeed = 80.f;
    
    // Init the board.
    _screenLeftBoard = 0;
    
    // Init the score.
    _points = 0;
    
    // Init the bomb number.
    _bombNum = 3;
    [self refreshBombLabel];
}

- (void) creaeInitObstacles {
    for (int i = 0; i < 4; i++) {
        [self spawnNewObstacle];
    }
}

- (void) addScore: (NSInteger)score {
    _points += score;
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_points];
}

- (void)spawnNewObstacle {
    CCNode *previousObstacle = [_obstacles lastObject];
    
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    if (!previousObstacle) {
        // this is the first obstacle
        
        // When the Balloons are cleared, the position should be in the new place.
        previousObstacleXPosition = _screenLeftBoard + firstObstaclePosition;
    }
    
    // To determine which to generate.
    CGFloat randomObstacle = ((double)arc4random() / ARC4RANDOM_MAX);
    CCNode *obstacle = NULL;
    if (randomObstacle < 0.8) {
        obstacle = [CCBReader load:@"obstacle"];
    } else {
        obstacle = [CCBReader load:@"plane"];
    }
    
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX);
    
    // 70: the lowest place.
    CGFloat range = 400 - 70;
    
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 200+ (random * range));
    
    [_pyhNode addChild:obstacle];
    [_obstacles addObject:obstacle];
    
    //NSLog(@"the position of obstacle: %f", obstacle.position.x);
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
        
        // Make the bomb button to be invisible.
        _bombButton.visible = FALSE;
        
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
        
        // Show the score board.
        [self showScoreBoard];
    }
}

- (void)showScoreBoard {
//    MyManager *sharedManager = [MyManager sharedManager];
//    
//    //CCLabelBMFont *label = [CCLabelBMFont labelWithString:[NSString stringWithString: sharedManager.SScore] fntFile:@"num.fnt"];
//    //CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"34" fntFile:@"num.fnt"];
//    //[self addChild:label];
//    
//    //- Create a CCLabelBMFont and add it on your Layer:
//    //CGSize size = [[CCDirector sharedDirector] winSize];
//    
//    
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
//    CGFloat screenWidth = screenRect.size.width;
//    CGFloat screenHeight = screenRect.size.height;
//    
//    CCLabelBMFont *label = [CCLabelBMFont labelWithString:@"Preview text" fntFile:@"num.fnt"];
//    // position the label on the center of the screen
//    label.position = ccp( screenWidth /2 , screenHeight/2 );
//    // add the label as a child to this Layer
//    [self addChild: label];
//
//    
//    //label.position = ccp(_screenLeftBoard + screenWidth/2+40, screenHeight-95);
//    label.position = ccp(_screenLeftBoard + screenWidth/2+40, screenHeight-200);
//    
//    // Get scores array stored in user defaults
//    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    // Get high scores array from “defaults” object
//    //NSMutableArray *highScores = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"scores"]];
//    
//    // Iterate thru high scores; see if current point value is higher than the stored values
//    //for (int i = 0; i < [highScores count]; i++)
//    {
//        //if (_points >= [[highScores objectAtIndex:i] intValue])
//        {
//            // Insert new high score, which pushes all others down
//            //[highScores insertObject:[NSNumber numberWithInt:_points] atIndex:i];
//            
//            // Remove last score, to make sure there are 5 enteries in the score array
//            //[highScores removeLastObject];
//            
//            // Re-save scores array to user defaults
//            //[defaults setObject:highScores forKey:@"scores"];
//            
//            //[defaults synchronize];
//            
//            NSLog(@"Saved new hgh score of %li", (long)_points);
//            
//            // Bust out of the loop
//            //break;
//        }
//    }
}

- (void)moveObjectRight:(CCNode*)node time:(CCTime)delta {
    node.position = ccp(node.position.x + delta * _scrollSpeed, node.position.y);
}

- (void)update:(CCTime)delta {    
    // Move the hero to the right in the world.
    [self moveObjectRight:_hero time:delta];
    
    /*
    NSLog(@"_wall1: %f, The _wall2: %f",
          _wall1.position.x,
          _wall2.position.x);
     */
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    _screenLeftBoard = _screenLeftBoard + delta * _scrollSpeed;
    CGFloat screenRightBoard = _screenLeftBoard + screenWidth;
    
    // Use this to detect the movement of the house.
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    
    CGFloat newXPosition = _hero.position.x + acceleration.x * 500 * delta;
    
    // Limit the range of the X and Y position in the screen.
    newXPosition = clampf(newXPosition, _screenLeftBoard, screenRightBoard);
    CGFloat newYPosition = clampf(_hero.position.y, 0, screenHeight);
    
    _hero.position = CGPointMake(newXPosition, newYPosition);
    
    _pyhNode.position = ccp(_pyhNode.position.x - delta * _scrollSpeed, _pyhNode.position.y);
    
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_pyhNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 3 * ground.contentSize.width, ground.position.y);
            
            // Add one score.
            [self addScore: 1];
        }
    }
    
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_pyhNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        
        //NSLog(@"The position: %f", obstacleScreenPosition.x);
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            NSLog(@"Delete one obstacle, The position: %f, the width: %f", obstacleScreenPosition.x, obstacle.contentSize.width);
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacle];
    }
    
    // If the obstacles are cleared, also create a new one.
    if (!_obstacles.count) {
        // Create 4 obstacles.
        [self creaeInitObstacles];
    }
}

@end
