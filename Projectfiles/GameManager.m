//
//  GameManager.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/6/12.
//
//

#import "GameManager.h"
#import "GalaxyGameLayer.h"

@implementation GameManager

+(void) startGalaxyScene1
{
    [[CCDirector sharedDirector] replaceScene:[GalaxyGameLayer scene]];
}

@end
