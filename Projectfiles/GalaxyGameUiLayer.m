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
    if(self = [super init]) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // copied from Rod Strougo, Ray Wenderlich: "Learning Cocos2D"
        float fontSize = 40.0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            fontSize *= 2;
        }
        distanceLabel = [CCLabelTTF labelWithString:@"" fontName:@"AmericanTypewriter-Bold" fontSize:fontSize];
        distanceLabel.anchorPoint = ccp(1, 1);
        distanceLabel.position =  ccp(winSize.width - 20, winSize.height - 20);
        
        timeLabel = [CCLabelTTF labelWithString:@"" fontName:@"AmericanTypewriter-Bold" fontSize:fontSize/2];
        timeLabel.anchorPoint = ccp(1, 1);
        timeLabel.position = ccp(winSize.width - 300, winSize.height - 20);
        
        roundLabel = [CCLabelTTF labelWithString:@"" fontName:@"AmericanTypewriter-Bold" fontSize:fontSize/4];
        roundLabel.anchorPoint = ccp(1, 1);
        roundLabel.position = ccp(winSize.width - 500, winSize.height - 20);
        
        [self addChild:distanceLabel];
        [self addChild:timeLabel];
        [self addChild:roundLabel];
    }
    
    return self;
}


#pragma mark GalaxyGameUiLayer

-(void) displayDistance:(float)distance
{
    NSString *text;
    if(distance > 1000) {
        text = @"";
    }
    else {
        int distanceInt = (int) roundf(distance);
        text = [NSString stringWithFormat:@"%d", distanceInt];
    }
    [distanceLabel setString:text];
}

-(void) displayTime:(int)remainingSeconds
{
    [timeLabel setString:[NSString stringWithFormat:@"%02d", remainingSeconds]];
}

-(void) displayRound:(int)round
{
    [roundLabel setString:[NSString stringWithFormat:@"%02d", round]];
}

@end
