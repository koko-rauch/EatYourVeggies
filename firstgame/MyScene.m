//
//  InitialScene.m
//  firstgame
//
//  Created by Komugi Saraie on 2/9/14.
//  Copyright (c) 2014 Komugi Saraie. All rights reserved.
//

#import "GameScene.h"
#import "MyScene.h"


@implementation MyScene

-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        // 1 Sets the background color to white, same as you did for the main scene.
        self.backgroundColor = [SKColor colorWithRed:0 green:0.9 blue:0 alpha:0];
        
        NSString * message;
        message = @"Make them eat VEGETABLES!";
        
        // 3 This is how you display a label of text to the screen with Sprite Kit. As you can see, it’s pretty easy – you just choose your font and set a few parameters.
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 20;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        
        // 4 Finally, this sets up and runs a sequence of two actions. I’ve included them all inline here to show you how handy that is (instead of having to make separate variables for each action). First it waits for 3 seconds, then it uses the runBlock action to run some arbitrary code.
        [self runAction:
         [SKAction sequence:@[
                              [SKAction waitForDuration:3.0],
                              [SKAction runBlock:^{
             // 5 This is how you transition to a new scene in Sprite Kit.
             // First you can pick from a variety of different animated transitions for how you want the scenes to display – you choose a flip transition here that takes 0.5 seconds.
             SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
               // Then you create the scene you want to display, and use the presentScene:transition: method on the self.view property.
             SKScene * myScene = [[GameScene alloc] initWithSize:self.size];
             [self.view presentScene:myScene transition: reveal];
         }]
                              ]]
         ];
        
    }
    return self;
}

@end