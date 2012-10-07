//
//  IntroLayer.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IntroLayer.h"
#import "GameManager.h"

#define INTRO_MUSIC_FILE @"intro.aifc"

@interface IntroLayer()
{
    
}

-(void) showTitle;
-(void) playMusic;
-(void) showMenu;
-(void) startGame;
@end

@implementation IntroLayer

#pragma mark NSObject

-(id) init
{
    if(self = [super init]) {
        [self playMusic];
        [self showTitle];
        [self showMenu];
    }
    
    return self;
}

#pragma mark IntroLayer

+(id) scene
{
	CCScene* scene = [CCScene node];
    IntroLayer* introLayer = [IntroLayer node];
    [scene addChild:introLayer];
    
    return scene;
}


#pragma mark privates

-(void) showTitle
{
    CGSize winsize = [CCDirector sharedDirector].screenSize;
    
    noGeekNoPokeLabel = [CCLabelTTF labelWithString:@"No Geek \nNo Poke" fontName:@"Chalkduster" fontSize:80];
    noGeekNoPokeLabel.anchorPoint = ccp(0.5, 0.5);
    noGeekNoPokeLabel.position =  ccp(winsize.width/2, winsize.height/2);

    CCTintTo *tintToRed = [CCTintTo actionWithDuration:5.0 red:255 green:0 blue:0];
    CCTintTo *tintToGreen = [CCTintTo actionWithDuration:5.0 red:0 green:255 blue:0];
    CCTintTo *tintToBlue = [CCTintTo actionWithDuration:5.0 red:0 green:0 blue:255];
    
    CCSequence *tintToSequence = [CCSequence actions:tintToRed, tintToGreen, tintToBlue, nil];
    CCRepeatForever *tintToForever = [CCRepeatForever actionWithAction:tintToSequence];
    CCFadeIn *fadeIn = [CCFadeIn actionWithDuration:10.0];
    
    [noGeekNoPokeLabel runAction:fadeIn];
    [noGeekNoPokeLabel runAction:tintToForever];

    [self addChild:noGeekNoPokeLabel];
    
    attributionLabel =  [CCLabelTTF labelWithString:@"Music '88' by steviekeys (licensed under CC BY-ND 3.0)" fontName:@"AmericanTypewriter-Bold" fontSize:10];
    attributionLabel.anchorPoint = ccp(0, 0);
    attributionLabel.position = ccp(10, 10);
    [self addChild:attributionLabel];
}

-(void) playMusic
{
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    [[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:YES];
    soundEngine = [SimpleAudioEngine sharedEngine];
    [soundEngine preloadBackgroundMusic:INTRO_MUSIC_FILE];
    [soundEngine playBackgroundMusic:INTRO_MUSIC_FILE];
}

-(void) showMenu
{
    CGSize winsize = [CCDirector sharedDirector].screenSize;
    
    CCLabelTTF *startGameButtonLabel = [CCLabelTTF labelWithString:@"Get me outa here!!!" fontName:@"Chalkduster" fontSize:20];
    
    startGameButton = [CCMenuItemLabel itemWithLabel:startGameButtonLabel target:self selector:@selector(startGame)];
    startGameButton.position = ccp(winsize.width - 200, 70);
    CCMenu *menu = [CCMenu menuWithItems:startGameButton, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
}

-(void) startGame
{
    [soundEngine stopBackgroundMusic];
    [GameManager startGalaxyScene1];
}

@end
