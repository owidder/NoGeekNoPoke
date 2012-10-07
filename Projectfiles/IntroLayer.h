//
//  IntroLayer.h
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "SimpleAudioEngine.h"

@interface IntroLayer : CCLayer {
    /**
     Shows 'No Geek No Poke'
     */
    CCLabelTTF *noGeekNoPokeLabel;
    
    /**
     Attributes the background music
     */
    CCLabelTTF *attributionLabel;
    
    /**
     Button to start the game
     */
    CCMenuItemLabel *startGameButton;
    
    SimpleAudioEngine *soundEngine;
}

+(id) scene;

@end
