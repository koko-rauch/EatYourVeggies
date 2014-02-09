//
//  GameOverScene.m
//  firstgame
//
//  Created by Komugi Saraie on 2/9/14.
//  Copyright (c) 2014 Komugi Saraie. All rights reserved.
//

//Here you imported the Sprite Kit header and marked that you are implementing a special initializer that takes a parameter of whether the user won the level or not in addition to the size.

#import "GameOverScene.h"
#import "GameScene.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size won:(BOOL)won {
    if (self = [super initWithSize:size]) {
        
        // 1 Sets the background color to white, same as you did for the main scene.
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        // 2 Based on the won parameter, sets the message to either “You Won” or “You Lose”.
        NSString * message;
        if (won) {
            message = @"You Won!";
        } else {
            message = @"You Lose :(";
        }
        
        // 3 This is how you display a label of text to the screen with Sprite Kit. As you can see, it’s pretty easy – you just choose your font and set a few parameters.
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];

        [self runAction:
            [SKAction sequence:@[
                [SKAction waitForDuration:3.0], //wait three seconds
                [SKAction runBlock:^{
             // 5 This is how you transition to a new scene in Sprite Kit.
             // First you can pick from a variety of different animated transitions for how you want the scenes to display – you choose a flip transition here that takes 0.5 seconds.
             // Then you create the scene you want to display, and use the presentScene:transition: method on the self.view property.
                    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
                    SKScene * myScene = [[GameScene alloc] initWithSize:self.size];
                    [self.view presentScene:myScene transition: reveal];
                }]
            ]]
        ];
        
        
    }
    return self;
}

@end