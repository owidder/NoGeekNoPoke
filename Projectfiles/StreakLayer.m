//
//  StreakLayer.h
//
//  Created by Oliver Widder
//  (Used a copy templayte from Steffen Itterheim (http://www.learn-cocos2d.com/store/book-learn-cocos2d/)
//

#import "StreakLayer.h"

@interface StreakLayer (PrivateMethods)
-(void) resetMotionStreak;
-(CCMotionStreak*) getMotionStreak;
@end

@implementation StreakLayer

+(id) scene
{
	CCScene* scene = [CCScene node];
	StreakLayer* layer = [StreakLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		self.isTouchEnabled = YES;
		[self resetMotionStreak];
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
}

-(void) resetMotionStreak
{
	// Removes the CCMotionStreak and creates a new one.
	[self removeChildByTag:StreakLayerTagMotionStreak cleanup:YES];
	CCMotionStreak* streak = [CCMotionStreak streakWithFade:20.0f
													 minSeg:5
													  width:30
													  color:ccc3(255, 0, 255)
											textureFilename:@"motionstreak2.png"];
	[self addChild:streak z:5 tag:StreakLayerTagMotionStreak];
	
	// changing the blend func can create nice effects
	// try out blend modes with the visual blend func tool: 
	// http://www.andersriggelsen.dk/glblendfunc.php
	streak.blendFunc = (ccBlendFunc){GL_ONE, GL_ONE};
}

-(CCMotionStreak*) getMotionStreak
{
	CCNode* node = [self getChildByTag:StreakLayerTagMotionStreak];
	NSAssert([node isKindOfClass:[CCMotionStreak class]], @"node is not a CCMotionStreak");
	
	return (CCMotionStreak*)node;
}

#if KK_PLATFORM_IOS
-(void) registerWithTouchDispatcher
{
	[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(void) moveMotionStreakToTouch:(UITouch*)touch
{
	CCMotionStreak* streak = [self getMotionStreak];
	streak.position = [self locationFromTouch:touch];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
	[self moveMotionStreakToTouch:touch];
	
	// Always swallow touches.
	return YES;
}

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
	[self moveMotionStreakToTouch:touch];
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
	// [self resetMotionStreak];
}
#endif

-(void) update:(ccTime)delta
{
#if KK_PLATFORM_MAC
	KKInput* input = [KKInput sharedInput];
	if ([input isMouseButtonDown:KKMouseButtonLeft])
	{
		CCMotionStreak* streak = [self getMotionStreak];
		streak.position = input.mouseLocation;
	}
#endif
}

@end
