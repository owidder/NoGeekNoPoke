//
//  GalaxyGameUiLayer.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 9/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GalaxyGameUiLayer.h"


@implementation GalaxyGameUiLayer

#pragma mark NSObject

-(id) init
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if(self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // copied from Rod Strougo, Ray Wenderlich: "Learning Cocos2D"
        float fontSize = 20.0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            fontSize *= 2;
        }
        timeLabel = [CCLabelTTF labelWithString:@"--" fontName:@"AmericanTypewriter-Bold" fontSize:fontSize/2];
        timeLabel.anchorPoint = ccp(1, 1);
        timeLabel.position = ccp(200, winSize.height - 20);
        
        roundLabel = [CCLabelTTF labelWithString:@"--" fontName:@"AmericanTypewriter-Bold" fontSize:fontSize/2];
        roundLabel.anchorPoint = ccp(1, 1);
        roundLabel.position = ccp(300, winSize.height - 20);
        
        roundPointsLabel = [CCLabelTTF labelWithString:@"-----" fontName:@"AmericanTypewriter-Bold" fontSize:fontSize/2];
        roundPointsLabel.anchorPoint = ccp(1, 1);
        roundPointsLabel.position = ccp(400, winSize.height - 20);
        
        totalPointsLabel = [CCLabelTTF labelWithString:@"------" fontName:@"AmericanTypewriter-Bold" fontSize:fontSize/2];
        totalPointsLabel.anchorPoint = ccp(1, 1);
        totalPointsLabel.position = ccp(winSize.width-20, winSize.height - 20);
        
        [self addChild:timeLabel];
        [self addChild:roundLabel];
        [self addChild:roundPointsLabel];
        [self addChild:totalPointsLabel];
    }
    
    return self;
}


#pragma mark GalaxyGameUiLayer

-(void) displayTime:(int)remainingSeconds
{
    [timeLabel setString:[NSString stringWithFormat:@"%02d", remainingSeconds]];
}

-(void) displayRound:(int)round
{
    [roundLabel setString:[NSString stringWithFormat:@"%02d", round]];
}

-(void) displayRoundPoints:(int)points
{
    [roundPointsLabel setString:[NSString stringWithFormat:@"%05d", points]];
}

-(void) displayTotalPoints:(int)points
{
    [totalPointsLabel setString:[NSString stringWithFormat:@"%06d", points]];
}

@end
