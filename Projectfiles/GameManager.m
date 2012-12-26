//
//  GameManager.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/6/12.
//
//

#import "GameManager.h"
#import "GalaxyGameLayer.h"
#import "IntroLayer.h"
#import "PileGameLayer.h"

@implementation GameManager

+(void) startIntro
{
    [[CCDirector sharedDirector] replaceScene:[IntroLayer scene]];
}

+(void) startGalaxyScene1
{
    [[CCDirector sharedDirector] replaceScene:[GalaxyGameLayer scene]];
}

+(void)startPileGameScene {
    [[CCDirector sharedDirector] replaceScene:[PileGameLayer scene]];
}

@end
