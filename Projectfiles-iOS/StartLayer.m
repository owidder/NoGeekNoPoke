//
//  StartScene.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 9/8/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "StartLayer.h"


@implementation StartLayer

+(id) scene
{
    CCScene *scene = [CCScene node];
    CCLayer *layer = [StartLayer node];
    [scene addChild:layer];
    
    return scene;
}

-(id) init
{
    if(self = [super init]) {
        CCLOG(@"%@:%@", NSStringFromSelector(_cmd), self);
    }
    
    return self;
}

-(void) dealloc
{
    CCLOG(@"%@:%@", NSStringFromSelector(_cmd), self);
}

@end
