//
//  StreakLayer.h
//
//  Created by Oliver Widder
//  (Used a copy templayte from Steffen Itterheim (http://www.learn-cocos2d.com/store/book-learn-cocos2d/)
//

#import "cocos2d.h"
#import "chipmunk.h"
#import "SimpleAudioEngine.h"

typedef enum
{
	kTagMotionStreak,
    kTagPlayer
} StreakLayerTags;

typedef enum {
    kNotStarted,
    kRunning,
    kIdle,
    kRoundEnded
} GameMode;

typedef enum {
    kPlayer, kGalaxy, kBorder, kFingerTip
} KindOfThing;

@class GalaxyGameUiLayer;
@class PointsLayer;

@interface GalaxyGameFieldLayer : CCLayer
{
    // the UI layer to display distance, points etc.
    GalaxyGameUiLayer *uiLayer;
    
    // the layer showing the current points
    PointsLayer *pointsLayer;
    
    /**
     Button to start a new game
     */
    CCMenuItem *newGameButton;

    /**
     Attributes the background music
     */
    CCLabelTTF *attributionLabel;
    
    SimpleAudioEngine *soundEngine;
}

-(id) initWithUiLayer:(GalaxyGameUiLayer*)pUiLayer andPointsLayer:(PointsLayer*)pPointsLayer;

@end
