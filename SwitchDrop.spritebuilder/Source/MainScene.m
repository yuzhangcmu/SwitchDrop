#import "MainScene.h"
#import "Block.h"

@implementation MainScene {
    Block *_currentBlock;
}

- (void)viewDidLoad {
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer
{
    // your code goes here...
}

#pragma mark - Touch Handling

- (id)initWithName:(NSString *)name identity:(int)index {
    self.userInteractionEnabled = YES;
}

- (void)touchBegan:(CCTouch *)touch withEvent:(UIEvent *)event {
    // create a penguin from the ccb-file
    
    CCNode* _currentBlock = (Block *)[CCBReader load:@"number1"];
    
    // initially position it on the scoop. 34,138 is the position in the node space of the _catapultArm
    //CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34, 138)];
    
    // transform the world position to the node space to which the penguin will be added (_physicsNode)
    //_currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
    
    // add it to the physics world
    //[_physicsNode addChild:_currentPenguin];
    // we don't want the penguin to rotate in the scoop
    //_currentPenguin.physicsBody.allowsRotation = NO;
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [_currentBlock.physicsBody applyForce:force];
    
}

@end



