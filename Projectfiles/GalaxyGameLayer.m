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

@implementation GalaxyGameLayer

#pragma mark -
#pragma mark static helper methods

/**
 Create a CCScene and add this layer as a child
 */
+(id) scene
{
	CCScene* scene = [CCScene node];
    GalaxyGameUiLayer *uiLayer = [GalaxyGameUiLayer node];
    GalaxyGameFieldLayer *fieldLayer = [[GalaxyGameFieldLayer alloc] initWithUiLayer:uiLayer];
    [scene addChild:uiLayer];
    [scene addChild:fieldLayer];
    
    return scene;
}



@end
