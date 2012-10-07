//
//  PointsLayer.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PointsLayer.h"
#import "RemoveFromParentAction.h"

#define GALAXY_POINTS_LABEL_FONT_NAME @"Chalkduster"
#define GALAXY_POINTS_LABEL_FONT_SIZE 20
#define GALAXY_POINTS_LABEL_FADE_IN_TIME 1.0
#define GALAXY_POINTS_LABEL_FADE_OUT_TIME 1.0
#define GALAXY_POINTS_LABEL_TINT_TO_TIME 0.5

#pragma mark extensions

@interface PointsLayer ()
{
    /**
     Only one galaxy points label is visible at a time
     */
    CCLabelTTF *currentVisibleGalaxyPointsLabel;
}

-(void) showGalaxyPoints:(int)points atPosition:(CGPoint)pos withLabel:(CCLabelTTF*)label;
-(void) makeColorActionForCurrentGalaxyPointsLabel;

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
    }
    
    return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);    
}

#pragma mark privates

-(void) makeColorActionForCurrentGalaxyPointsLabel
{
    if(currentVisibleGalaxyPointsLabel != nil) {
        [currentVisibleGalaxyPointsLabel stopAllActions];
        
        CCTintTo *tintToWhite = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:255 green:255 blue:255];
        if(currentVisibleGalaxyPointsLabel == redGalaxyPointsLabel) {
            CCTintTo *tintToRed = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:255 green:0 blue:0];
            CCSequence *tintToSequence = [CCSequence actions:tintToRed, tintToWhite, nil];
            [currentVisibleGalaxyPointsLabel runAction:[CCRepeatForever actionWithAction:tintToSequence]];
        }
        else if(currentVisibleGalaxyPointsLabel == blueGalaxyPointsLabel) {
            CCTintTo *tintToBlue = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:0 green:0 blue:255];
            CCSequence *tintToSequence = [CCSequence actions:tintToBlue, tintToWhite, nil];
            [currentVisibleGalaxyPointsLabel runAction:[CCRepeatForever actionWithAction:tintToSequence]];
        }
        else if(currentVisibleGalaxyPointsLabel == greenGalaxyPointsLabel) {
            CCTintTo *tintToGreen = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:0 green:255 blue:0];
            CCSequence *tintToSequence = [CCSequence actions:tintToGreen, tintToWhite, nil];
            [currentVisibleGalaxyPointsLabel runAction:[CCRepeatForever actionWithAction:tintToSequence]];
        }
        else if(currentVisibleGalaxyPointsLabel == rgbGalaxyPointsLabel) {
            CCTintTo *tintToRed = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:255 green:0 blue:0];
            CCTintTo *tintToBlue = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:0 green:0 blue:255];
            CCTintTo *tintToGreen = [CCTintTo actionWithDuration:GALAXY_POINTS_LABEL_TINT_TO_TIME red:0 green:255 blue:0];
            CCSequence *tintToSequence = [CCSequence actions:tintToBlue, tintToGreen, tintToRed, tintToWhite, nil];
            [currentVisibleGalaxyPointsLabel runAction:[CCRepeatForever actionWithAction:tintToSequence]];
        }
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

    if(label != currentVisibleGalaxyPointsLabel) {
        if(currentVisibleGalaxyPointsLabel != nil) {
            [self removeCurrentGalaxyLabel];
        }
        
        currentVisibleGalaxyPointsLabel = label;
        [currentVisibleGalaxyPointsLabel runAction:[CCFadeIn actionWithDuration:GALAXY_POINTS_LABEL_FADE_IN_TIME]];
        [self makeColorActionForCurrentGalaxyPointsLabel];
        
        if([currentVisibleGalaxyPointsLabel parent] == nil) {
            [self addChild:currentVisibleGalaxyPointsLabel];
        }
    }
}

#pragma mark PointsLayer

-(void) showRedGalaxyPoints:(int)points atPosition:(CGPoint)pos
{
    [self showGalaxyPoints:points atPosition:pos withLabel:redGalaxyPointsLabel];
}

-(void) showBlueGalaxyPoints:(int)points atPosition:(CGPoint)pos
{
    [self showGalaxyPoints:points atPosition:pos withLabel:blueGalaxyPointsLabel];
}

-(void) showGreenGalaxyPoints:(int)points atPosition:(CGPoint)pos
{
    [self showGalaxyPoints:points atPosition:pos withLabel:greenGalaxyPointsLabel];
}

-(void) showRgbGalaxyPoints:(int)points atPosition:(CGPoint)pos
{
    [self showGalaxyPoints:points atPosition:pos withLabel:rgbGalaxyPointsLabel];
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

@end
