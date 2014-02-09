//
//  MyScene.m
//  firstgame
//
//  Created by Komugi Saraie on 2/9/14.
//  Copyright (c) 2014 Komugi Saraie. All rights reserved.
//

#import "MyScene.h"
#import "GameScene.h"
#import "GameOverScene.h"

static const uint32_t veg = 0x1 << 0;
static const uint32_t girl = 0x1 << 1;

// create private interface
@interface GameScene () <SKPhysicsContactDelegate>
@property (nonatomic) SKSpriteNode * player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@property (nonatomic) int childrenVegged;
@property (nonatomic) int level;
@end

// vector methods
static inline CGPoint rwAdd(CGPoint a, CGPoint b) { return CGPointMake(a.x + b.x, a.y + b.y); }
static inline CGPoint rwSub(CGPoint a, CGPoint b) { return CGPointMake(a.x - b.x, a.y - b.y); }
static inline CGPoint rwMult(CGPoint a, float b) { return CGPointMake(a.x * b, a.y * b); }
static inline float rwLength(CGPoint a) { return sqrtf(a.x * a.x + a.y * a.y); }

// Makes a vector have a length of 1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}

@implementation GameScene

- (void)someMethod {
    self.level = 5;
}

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        // size of screen
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // background colour
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // Add a sprite using spriteNodeWithImageNamed method, and pass in the name of the image.
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"mother"];
        
        // set sprite position to half the width and half the height and addChild to screen
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        [self addChild:self.player];
        
        //This sets up the physics world to have no gravity, and sets the scene as the delegate to be notified when two physics bodies collide.
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

- (void)addChild {
    
    // Create sprite
    SKSpriteNode * child = [SKSpriteNode spriteNodeWithImageNamed:@"girl"];
    
    // Creates a physics body for the sprite. In this case, the body is defined as a rectangle of the same size of the sprite, because that’s a decent approximation for the child.
    child.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:child.size];
    
    // Sets the sprite to be dynamic. This means that the physics engine will not control the movement of the child – you will through the code you’ve already written (using move actions).
    child.physicsBody.dynamic = YES;
    
    // Sets the category bit mask to be the childCategory you defined earlier.
    child.physicsBody.categoryBitMask = girl;
    
    // The contactTestBitMask indicates what categories of objects this object should notify the contact listener when they intersect. You choose veggies here.
    child.physicsBody.contactTestBitMask = veg;
    
    // The collisionBitMask indicates what categories of objects this object that the physics engine handle contact responses to (i.e. bounce off of). You don’t want the child and veggie to bounce off each other – it’s OK for them to go right through each other in this game – so you set this to 0.
    child.physicsBody.collisionBitMask = 0;
    
    // Determine where to spawn the child along the Y axis
    int minY = child.size.height / 2;
    int maxY = self.frame.size.height - child.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the child slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    child.position = CGPointMake(0, actualY);
    [self addChild:child];
    
    // Determine speed of the child
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    SKAction * actionMove = [SKAction moveTo:CGPointMake(self.frame.size.width, actualY) duration:actualDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    //This creates a new “lose action” that displays the game over scene when a child goes off-screen. See if you understand each line here, if not refer to the explanation for the previous code block.
    SKAction * loseAction = [SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition: reveal];
    }];
    [child runAction:[SKAction sequence:@[actionMove, loseAction, actionMoveDone]]];
    
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addChild];
    }
}

- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    //play sound when shooting projrctiles
    [self runAction:[SKAction playSoundFileNamed:@"eatVeg.caf" waitForCompletion:NO]];
    
    // 1 - Choose one of the touches to work with
    UITouch * touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // 2 - Set up initial location of veggie
    NSString * vegetable;
    if (self.level<=2){
        vegetable = @"carrot";
    }else{
       vegetable = @"tomato";
    }
    
    SKSpriteNode * veggie = [SKSpriteNode spriteNodeWithImageNamed:vegetable];
    veggie.position = self.player.position;
    
    //create physics body around veggie
    veggie.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:veggie.size.width/2];
    //dynamic - you control their movement
    veggie.physicsBody.dynamic = YES;
    // set to the bit mask you set in the beggining
    veggie.physicsBody.categoryBitMask = veg;
    // set so it returns a response when collision with child
    veggie.physicsBody.contactTestBitMask = girl;
    // but let them go through each other
    veggie.physicsBody.collisionBitMask = 0;
    
    // You also set usesPreciseCollisionDetection to true. This is important to set for fast moving bodies (like veggies), because otherwise there is a chance that two fast moving bodies can pass through each other without a collision being detected.
    veggie.physicsBody.usesPreciseCollisionDetection = YES;
    
    // 3- Determine offset of location to veggie
    CGPoint offset = rwSub(location, veggie.position);
    
    // 4 - Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // 5 - OK to add now - we've double checked position
    [self addChild:veggie];
    
    // 6 - Get the direction of where to shoot
    CGPoint direction = rwNormalize(offset);
    
    // 7 - Make it shoot far enough to be guaranteed off screen
    CGPoint shootAmount = rwMult(direction, 1000);
    
    // 8 - Add the shoot amount to the current position
    CGPoint realDest = rwAdd(shootAmount, veggie.position);
    
    // 9 - Create the actions
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width / velocity;
    SKAction * actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction * actionMoveDone = [SKAction removeFromParent];
    [veggie runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)veggie:(SKSpriteNode *)veggie didCollideWithChild:(SKSpriteNode *)child {
    NSLog(@"Hit");
    [veggie removeFromParent];
    [child removeFromParent];
    
    self.childrenVegged++;
    
    // hit count goes up by level
    int num_vegged;
    if (self.level<=2){
        num_vegged = 10;
    }else{
        num_vegged = 20;
    }
    
    if (self.childrenVegged == num_vegged) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:YES];
        [self.view presentScene:gameOverScene transition: reveal];
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1 This method passes you the two bodies that collide, but does not guarantee that they are passed in any particular order. So this bit of code just arranges them so they are sorted by their category bit masks so you can make some assumptions later. This bit of code came from Apple’s Adventure sample.
    
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2 Finally, it checks to see if the two bodies that collide are the veggie and child, and if so calls the method you wrote earlier.
    
    if ((firstBody.categoryBitMask & veg) != 0 &&
        (secondBody.categoryBitMask & girl) != 0)
    {
        [self veggie:(SKSpriteNode *) firstBody.node didCollideWithChild:(SKSpriteNode *) secondBody.node];
    }
}
@end