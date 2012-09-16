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
    kTagParticleSystem
} StreakLayerTags;

@interface StreakLayer : CCLayer
{
    cpSpace *space;
}

+(id) scene;

@end
