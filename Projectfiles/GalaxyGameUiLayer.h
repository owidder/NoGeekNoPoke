//
//  GalaxyGameUiLayer.h
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 9/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GalaxyGameUiLayer : CCLayer {
    CCLabelTTF *timeLabel;
    CCLabelTTF *roundLabel;
    CCLabelTTF *roundPointsLabel;
    CCLabelTTF *totalPointsLabel;
}

/**
 Show the remaining time for each round
 */
-(void) displayTime:(int)remainingSeconds;

/**
 Show the round number
 */
-(void) displayRound:(int)round;

/**
 Show the current points of this round
 */
-(void) displayRoundPoints:(int)points;

/**
 Show the current total points
 */
-(void) displayTotalPoints:(int)points;

@end
