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
    CCLabelTTF *distanceLabel;
    CCLabelTTF *timeLabel;
    CCLabelTTF *roundLabel;
}

/**
 show the min distance with the distanceLabel
 */
-(void) displayDistance:(float)distance;

/**
 Show the remaining time for each round
 */
-(void) displayTime:(int)remainingSeconds;

/**
 Show the round number
 */
-(void) displayRound:(int)round;

@end
