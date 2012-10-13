//
//  PointsLayer.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PointsLayer.h"
#import "RemoveFromParentAction.h"
#import "SetStringAction.h"

#define GALAXY_POINTS_LABEL_FONT_NAME @"Georgia"
#define GALAXY_POINTS_LABEL_FONT_SIZE 20
#define GALAXY_POINTS_LABEL_FADE_IN_TIME 0.5
#define GALAXY_POINTS_LABEL_FADE_OUT_TIME 1.0
#define GALAXY_POINTS_LABEL_TINT_TO_TIME 1.0

#define ROUND_POINTS_LABEL_FONT_NAME @"Optima"
#define ROUND_POINTS_LABEL_FONT_SIZE 100
#define ROUND_POINTS_LABEL_FADE_IN_TIME 0.3
#define ROUND_POINTS_LABEL_FADE_OUT_TIME 3.0

#define WINNER_LOSER_LABEL_FONT_NAME @"Optima"
#define WINNER_LOSER_LABEL_FONT_SIZE 100
#define WINNER_LOSER_LABEL_FADE_IN_TIME 0.1
#define WINNER_LOSER_LABEL_FADE_OUT_TIME 3.0

#pragma mark extensions

@interface PointsLayer ()
{
    /**
     Only one galaxy points label is visible at a time
     */
    CCLabelTTF *currentVisibleGalaxyPointsLabel;
}

-(void) showGalaxyPoints:(int)points atPosition:(CGPoint)pos withLabel:(CCLabelTTF*)label;
-(void) runColorActionForCurrentGalaxyPointsLabel:(NSTimer*)timer;
-(void) showWinnerLoserLabelWithText:(NSString*)text;

@end


@implementation PointsLayer

#pragma mark NSObject

-(id) init
{
    if(self = [super init]) {
        currentVisibleGalaxyPointsLabel = nil;
        
        redGalaxyPointsLabel = [CCLabelTTF labelWithString:@"" fontName:GALAXY_POINTS_LABEL_FONT_NAME fontSize:GALAXY_POINTS_LABEL_FONT_SIZE];
        blueGalaxyPointsLabel = [CCLabelTTF labelWithString:@"" fontName:GALAXY_POINTS_LABEL_FONT_NAME fontSize:GALAXY_POINTS_LABEL_FONT_SIZE];
        greenGalaxyPointsLabel = [CCLabelTTF labelWithString:@"" fontName:GALAXY_POINTS_LABEL_FONT_NAME fontSize:GALAXY_POINTS_LABEL_FONT_SIZE];
        rgbGalaxyPointsLabel = [CCLabelTTF labelWithString:@"" fontName:GALAXY_POINTS_LABEL_FONT_NAME fontSize:GALAXY_POINTS_LABEL_FONT_SIZE];
        roundPointsLabel = [CCLabelTTF labelWithString:@"" fontName:ROUND_POINTS_LABEL_FONT_NAME fontSize:ROUND_POINTS_LABEL_FONT_SIZE];
        winnerLoserLabel = [CCLabelTTF labelWithString:@"" fontName:WINNER_LOSER_LABEL_FONT_NAME fontSize:WINNER_LOSER_LABEL_FONT_SIZE];
        
        redGalaxyPointsLabel.opacity = 0;
        blueGalaxyPointsLabel.opacity = 0;
        greenGalaxyPointsLabel.opacity = 0;
        rgbGalaxyPointsLabel.opacity = 0;
        
        [self addChild:redGalaxyPointsLabel];
        [self addChild:blueGalaxyPointsLabel];
        [self addChild:greenGalaxyPointsLabel];
        [self addChild:rgbGalaxyPointsLabel];
        [self addChild:roundPointsLabel];
        [self addChild:winnerLoserLabel];
        
        CGSize winSize = [CCDirector sharedDirector].screenSize;
        CGPoint startPosition = ccp(winSize.width/2, winSize.height/2);
        winnerLoserLabel.position = startPosition;
        redGalaxyPointsLabel.position = startPosition;
        greenGalaxyPointsLabel.position = startPosition;
        blueGalaxyPointsLabel.position = startPosition;
        rgbGalaxyPointsLabel.position = startPosition;
        roundPointsLabel.position = startPosition;
    }
    
    return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);    
}

#pragma mark privates

-(void) showWinnerLoserLabelWithText:(NSString *)text
{
    winnerLoserLabel.string = text;
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:WINNER_LOSER_LABEL_FADE_IN_TIME];
    CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:WINNER_LOSER_LABEL_FADE_OUT_TIME];
    SetStringAction *setEmptyString = [SetStringAction actionWithString:@""];
    CCSequence *seq = [CCSequence actions:fadeIn, fadeOut, setEmptyString, nil];
    
    [winnerLoserLabel runAction:seq];
}

-(void) runColorActionForCurrentGalaxyPointsLabel:(NSTimer*)timer
{
    if(currentVisibleGalaxyPointsLabel != nil) {
        
        CCSequence *tintToSequence = nil;
        [currentVisibleGalaxyPointsLabel stopAllActions];
        
        CCTintTo *tintToWhite = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:255 green:255 blue:255];
        if(currentVisibleGalaxyPointsLabel == redGalaxyPointsLabel) {
            CCTintTo *tintToRed = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:255 green:0 blue:0];
            tintToSequence = [CCSequence actions:tintToRed, tintToWhite, nil];
        }
        else if(currentVisibleGalaxyPointsLabel == blueGalaxyPointsLabel) {
            CCTintTo *tintToBlue = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:0 green:0 blue:255];
            tintToSequence = [CCSequence actions:tintToBlue, tintToWhite, nil];
        }
        else if(currentVisibleGalaxyPointsLabel == greenGalaxyPointsLabel) {
            CCTintTo *tintToGreen = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:0 green:255 blue:0];
            tintToSequence = [CCSequence actions:tintToGreen, tintToWhite, nil];
            [currentVisibleGalaxyPointsLabel runAction:[CCRepeatForever actionWithAction:tintToSequence]];
        }
        else if(currentVisibleGalaxyPointsLabel == rgbGalaxyPointsLabel) {
            CCTintTo *tintToRed = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:255 green:0 blue:0];
            CCTintTo *tintToBlue = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:0 green:0 blue:255];
            CCTintTo *tintToGreen = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:0 green:255 blue:0];
            tintToSequence = [CCSequence actions:tintToBlue, tintToGreen, tintToRed, tintToWhite, nil];
        }
        
        [currentVisibleGalaxyPointsLabel runAction:[CCRepeatForever actionWithAction:tintToSequence]];
    }
}

-(void) showGalaxyPoints:(int)points atPosition:(CGPoint)pos withLabel:(CCLabelTTF *)label
{
    CGSize winSize = [CCDirector sharedDirector].screenSize;
    
    pos.x = min(pos.x, winSize.width - 30);
    pos.x = max(pos.x, 100);
    pos.y = min(pos.y, winSize.height - 30);
    pos.y = max(pos.y, 100);

    label.position = pos;
    label.string = [NSString stringWithFormat:@"%d", points];
    label.fontSize = max(min(points, 500), 20);

    if(label != currentVisibleGalaxyPointsLabel) {
        currentVisibleGalaxyPointsLabel.string = @"";
        
        [label runAction:[CCFadeIn actionWithDuration:GALAXY_POINTS_LABEL_FADE_IN_TIME]];
        [NSTimer scheduledTimerWithTimeInterval:GALAXY_POINTS_LABEL_FADE_IN_TIME*2 target:self selector:@selector(runColorActionForCurrentGalaxyPointsLabel:) userInfo:nil repeats:NO];
        currentVisibleGalaxyPointsLabel = label;
    }
}

#pragma mark PointsLayer

-(void) showRedGalaxyPoints:(int)points atPosition:(CGPoint)pos
{
    if(points > 0) {
        [self showGalaxyPoints:points atPosition:pos withLabel:redGalaxyPointsLabel];
    }
}

-(void) showBlueGalaxyPoints:(int)points atPosition:(CGPoint)pos
{
    if(points > 0) {
        [self showGalaxyPoints:points atPosition:pos withLabel:blueGalaxyPointsLabel];
    }
}

-(void) showGreenGalaxyPoints:(int)points atPosition:(CGPoint)pos
{
    if(points > 0) {
        [self showGalaxyPoints:points atPosition:pos withLabel:greenGalaxyPointsLabel];
    }
}

-(void) showRgbGalaxyPoints:(int)points atPosition:(CGPoint)pos
{
    if(points > 0) {
        [self showGalaxyPoints:points atPosition:pos withLabel:rgbGalaxyPointsLabel];
    }
}

-(void) showRoundPoints:(int)points atPosition:(CGPoint)pos
{
    if(points > 0) {
        CGSize winSize = [CCDirector sharedDirector].screenSize;
        
        pos.x = min(pos.x, winSize.width - 300);
        pos.x = max(pos.x, 300);
        pos.y = min(pos.y, winSize.height - 300);
        pos.y = max(pos.y, 300);
        
        roundPointsLabel.position = pos;
        roundPointsLabel.string = [NSString stringWithFormat:@"%d", points];
        roundPointsLabel.fontSize = max(min(points*3, 150), 50);
        roundPointsLabel.opacity = 0;

        CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:ROUND_POINTS_LABEL_FADE_IN_TIME];
        CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:ROUND_POINTS_LABEL_FADE_OUT_TIME];
        SetStringAction *setEmptyString = [SetStringAction actionWithString:@""];
        CCSequence *seq = [CCSequence actions:fadeIn, fadeOut, setEmptyString, nil];
        [roundPointsLabel runAction:seq];
    }
}

-(void) hideCurrentGalaxyLabel
{
    if(currentVisibleGalaxyPointsLabel != nil) {
        [currentVisibleGalaxyPointsLabel stopAllActions];
        CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:GALAXY_POINTS_LABEL_FADE_OUT_TIME];
        SetStringAction *setEmptyString = [SetStringAction actionWithString:@""];
        
        CCSequence *fadeOutAndSetEmptyString = [CCSequence actions:fadeOut, setEmptyString, nil];
        [currentVisibleGalaxyPointsLabel runAction:fadeOutAndSetEmptyString];
        
        currentVisibleGalaxyPointsLabel = nil;
    }
}

-(void) hideAllLabels
{
    [self hideCurrentGalaxyLabel];
    SetStringAction *setEmptyString = [SetStringAction actionWithString:@""];
    CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:ROUND_POINTS_LABEL_FADE_OUT_TIME];
    CCSequence *seq = [CCSequence actions:fadeOut, setEmptyString, nil];
    [roundPointsLabel runAction:seq];
    
    redGalaxyPointsLabel.string = @"";
    greenGalaxyPointsLabel.string = @"";
    blueGalaxyPointsLabel.string = @"";
    rgbGalaxyPointsLabel.string = @"";
}

-(void) win
{
    [self showWinnerLoserLabelWithText:@"WINNER"];
}

-(void)lose
{
    [self showWinnerLoserLabelWithText:@"LOSER"];
}

@end
