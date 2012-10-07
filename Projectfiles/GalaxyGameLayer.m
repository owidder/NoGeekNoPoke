//
//  GalaxyGameLayer.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 9/30/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "GalaxyGameLayer.h"
#import "GalaxyGameUiLayer.h"
#import "GalaxyGameFieldLayer.h"
#import "PointsLayer.h"

@implementation GalaxyGameLayer

#pragma mark NSObject

-(id) init
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if(self = [super init]) {
    }
    
    return self;
}

-(void) dealloc
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
}

#pragma mark -
#pragma mark static helper methods

/**
 Create a CCScene and add this layer as a child
 */
+(id) scene
{
	CCScene* scene = [CCScene node];
    GalaxyGameUiLayer *uiLayer = [GalaxyGameUiLayer node];
    PointsLayer *pointsLayer = [[PointsLayer alloc] init];
    GalaxyGameFieldLayer *fieldLayer = [[GalaxyGameFieldLayer alloc] initWithUiLayer:uiLayer andPointsLayer:pointsLayer];
    [scene addChild:pointsLayer];
    [scene addChild:fieldLayer];
    [scene addChild:uiLayer];
    
    return scene;
}



@end
