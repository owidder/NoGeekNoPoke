//
//  StreakLayer.h
//
//  Created by Oliver Widder
//  (Used a copy templayte from Steffen Itterheim (http://www.learn-cocos2d.com/store/book-learn-cocos2d/)
//

#import "cocos2d.h"
#import "chipmunk.h"

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
    kPlayer, kGalaxy, kBorder
} KindOfThing;

@class GalaxyGameUiLayer;

@interface GalaxyGameFieldLayer : CCLayer
{
    // the UI layer to display distance, points etc.
    GalaxyGameUiLayer *uiLayer;
}

-(id) initWithUiLayer:(GalaxyGameUiLayer*)pUiLayer;

@end
