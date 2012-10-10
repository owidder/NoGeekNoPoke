//
//  PointsLayer.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PointsLayer.h"
#import "RemoveFromParentAction.h"

#define GALAXY_POINTS_LABEL_FONT_NAME @"Georgia"
#define ROUND_POINTS_LABEL_FONT @"Optima"
#define GALAXY_POINTS_LABEL_FONT_SIZE 20
#define ROUND_POINTS_LABEL_FONT_SIZE 100
#define GALAXY_POINTS_LABEL_FADE_IN_TIME 0.1
#define GALAXY_POINTS_LABEL_FADE_OUT_TIME 1.0
#define GALAXY_POINTS_LABEL_TINT_TO_TIME 5.0
#define ROUND_POINTS_LABEL_FADE_IN_TIME 0.2
#define ROUND_POINTS_LABEL_FADE_OUT_TIME 3.0

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
        roundPointsLabel = [CCLabelTTF labelWithString:@"" fontName:ROUND_POINTS_LABEL_FONT fontSize:ROUND_POINTS_LABEL_FONT_SIZE];
        
        [self addChild:roundPointsLabel];
    }
    
    return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);    
}

#pragma mark privates

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
        if(currentVisibleGalaxyPointsLabel != nil) {
            [self removeCurrentGalaxyLabel];
        }
        
        currentVisibleGalaxyPointsLabel = label;
        if([currentVisibleGalaxyPointsLabel parent] == nil) {
            [self addChild:currentVisibleGalaxyPointsLabel];
        }
        [currentVisibleGalaxyPointsLabel runAction:[CCFadeIn actionWithDuration:GALAXY_POINTS_LABEL_FADE_IN_TIME]];
        [NSTimer scheduledTimerWithTimeInterval:GALAXY_POINTS_LABEL_FADE_IN_TIME*2 target:self selector:@selector(runColorActionForCurrentGalaxyPointsLabel:) userInfo:nil repeats:NO];
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
        
        CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:ROUND_POINTS_LABEL_FADE_IN_TIME];
        CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:ROUND_POINTS_LABEL_FADE_OUT_TIME];
        CCSequence *seq = [CCSequence actions:fadeIn, fadeOut, nil];
        [roundPointsLabel runAction:seq];
        if([roundPointsLabel parent] == nil) {
            [self addChild:roundPointsLabel];
        }
        
        roundPointsLabel.position = pos;
        roundPointsLabel.string = [NSString stringWithFormat:@"%d", points];
        roundPointsLabel.fontSize = max(min(points*3, 1000), 100);
    }
}

-(void) removeCurrentGalaxyLabel
{
    if(currentVisibleGalaxyPointsLabel != nil) {
        [currentVisibleGalaxyPointsLabel stopAllActions];
        CCFadeOut *fadeOut = [CCFadeOut actionWithDuration:GALAXY_POINTS_LABEL_FADE_OUT_TIME];
        RemoveFromParentAction *remove = [RemoveFromParentAction action];
        
        CCSequence *fadeOutAndRemove = [CCSequence actions:fadeOut, remove, nil];
        [currentVisibleGalaxyPointsLabel runAction:fadeOutAndRemove];
        currentVisibleGalaxyPointsLabel = nil;
    }
}

-(void) removeAll
{
    [self removeCurrentGalaxyLabel];
    [roundPointsLabel runAction:[CCFadeOut actionWithDuration:ROUND_POINTS_LABEL_FADE_OUT_TIME]];
}

@end
