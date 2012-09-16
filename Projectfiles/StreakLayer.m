//
//  StreakLayer.h
//
//  Created by Oliver Widder
//  (Used a copy templayte from Steffen Itterheim (http://www.learn-cocos2d.com/store/book-learn-cocos2d/)
//

#import "StreakLayer.h"

static int playerCtr = 0;

// C callback method that updates sprite position and rotation:
static void forEachShape(cpShape* shape, void* data)
{
	CCSprite* sprite = (__bridge CCSprite*)shape->data;
	if (sprite != nil)
	{
		cpBody* body = shape->body;
		sprite.position = body->p;
		sprite.rotation = CC_RADIANS_TO_DEGREES(body->a) * -1;
	}
}

@interface StreakLayer ()
-(void) resetMotionStreak;
-(CCMotionStreak*) getMotionStreak;
-(void) addNewPlayerAt:(CGPoint)pos;
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
		space = cpSpaceNew();
		space->iterations = 8;
		space->gravity = CGPointMake(0, -200);
		
		// Add the collision handlers
        //		unsigned int defaultCollisionType = 0;
        //		cpSpaceAddCollisionHandler(space, defaultCollisionType, defaultCollisionType,
        //								   &contactBegin, NULL, NULL, &contactEnd, NULL);
		
		// for the ground body we'll need these values
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CGPoint lowerLeftCorner = CGPointMake(0, 0);
		CGPoint lowerRightCorner = CGPointMake(screenSize.width, 0);
		CGPoint upperLeftCorner = CGPointMake(0, screenSize.height);
		CGPoint upperRightCorner = CGPointMake(screenSize.width, screenSize.height);
		
		// Create the static body that keeps objects within the screen area
		float mass = INFINITY;
		float inertia = INFINITY;
		cpBody* staticBody = cpBodyNew(mass, inertia);
		
		cpShape* shape;
		float elasticity = 1.0f;
		float friction = 1.0f;
		float radius = 0.0f;
		
		// bottom
		shape = cpSegmentShapeNew(staticBody, lowerLeftCorner, lowerRightCorner, radius);
		shape->e = elasticity;
		shape->u = friction;
		cpSpaceAddStaticShape(space, shape);
		
		// top
		shape = cpSegmentShapeNew(staticBody, upperLeftCorner, upperRightCorner, radius);
		shape->e = elasticity;
		shape->u = friction;
		cpSpaceAddStaticShape(space, shape);
		
		// left
		shape = cpSegmentShapeNew(staticBody, lowerLeftCorner, upperLeftCorner, radius);
		shape->e = elasticity;
		shape->u = friction;
		cpSpaceAddStaticShape(space, shape);
		
		// right
		shape = cpSegmentShapeNew(staticBody, lowerRightCorner, upperRightCorner, radius);
		shape->e = elasticity;
		shape->u = friction;
		cpSpaceAddStaticShape(space, shape);
		
        CCNode *particleNode = [CCNode node];
        [self addChild:particleNode z:0 tag:kTagParticleSystem];
		
		[KKInput sharedInput].accelerometerActive = YES;
        
		self.isTouchEnabled = YES;
		[self resetMotionStreak];
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    cpSpaceFree(space);
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

-(CCParticleSystem*) addParticleSystemAt:(CGPoint)pos
{
    CCNode *particleNode = (CCNode*) [self getChildByTag:kTagParticleSystem];
    
    CCParticleSystemQuad *psq;
    
    switch (playerCtr++) {
        case 0:
            psq = [CCParticleSystemQuad particleWithFile:@"playerBlue.plist"];
            break;
            
        case 1:
            psq = [CCParticleSystemQuad particleWithFile:@"playerRed.plist"];
            break;
            
        case 2:
            psq = [CCParticleSystemQuad particleWithFile:@"playerGreen.plist"];
            playerCtr = 0;
            break;
            
        default:
            psq = [CCParticleSystemQuad particleWithFile:@"playerBlue.plist"];
            playerCtr = 1;
            break;
    }
    
    
    psq.position = pos;
    
    [particleNode addChild:psq];
    
    return psq;
}

-(void) resetMotionStreak
{
	// Removes the CCMotionStreak and creates a new one.
	[self removeChildByTag:kTagMotionStreak cleanup:YES];
	CCMotionStreak* streak = [CCMotionStreak streakWithFade:20.0f
													 minSeg:5
													  width:30
													  color:ccc3(255, 0, 255)
											textureFilename:@"motionstreak2.png"];
	[self addChild:streak z:5 tag:kTagMotionStreak];
	
	// changing the blend func can create nice effects
	// try out blend modes with the visual blend func tool: 
	// http://www.andersriggelsen.dk/glblendfunc.php
	streak.blendFunc = (ccBlendFunc){GL_ONE, GL_ONE};
}


-(void) addNewPlayerAt:(CGPoint)pos
{
	float mass = 5.5f;
	float moment = cpMomentForCircle(mass, 10, 10, CGPointZero);
	cpBody* body = cpBodyNew(mass, moment);
	
	body->p = pos;
	cpSpaceAddBody(space, body);
	
	float elasticity = 0.9f;
	float friction = 0.7f;
	
    cpShape *shape = cpCircleShapeNew(body, 10, CGPointZero);
	shape->e = elasticity;
	shape->u = friction;
	shape->data = (__bridge void*)[self addParticleSystemAt:pos];
	cpSpaceAddShape(space, shape);
}

-(CCMotionStreak*) getMotionStreak
{
	CCNode* node = [self getChildByTag:kTagMotionStreak];
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
    [self resetMotionStreak];
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
    [self resetMotionStreak];
    [self addNewPlayerAt:[self locationFromTouch:touch]];
}
#endif

-(void) update:(ccTime)delta
{
	CCDirector* director = [CCDirector sharedDirector];
	if (director.currentPlatformIsIOS)
	{
		KKInput* input = [KKInput sharedInput];
		if (director.currentDeviceIsSimulator == NO)
		{
			KKAcceleration* acceleration = input.acceleration;
			space->gravity = cpv(500.0f * acceleration.rawX, 500.0f * acceleration.rawY);
		}
		
		if (input.anyTouchEndedThisFrame)
		{
			[self addNewPlayerAt:[input locationOfAnyTouchInPhase:KKTouchPhaseEnded]];
		}
	}
	else if (director.currentPlatformIsMac)
	{
		KKInput* input = [KKInput sharedInput];
		if (input.isAnyMouseButtonUpThisFrame || CGPointEqualToPoint(input.scrollWheelDelta, CGPointZero) == NO)
		{
			[self addNewPlayerAt:input.mouseLocation];
		}
	}
	
	float timeStep = 0.03f;
	cpSpaceStep(space, timeStep);
	
	// call forEachShape C method to update sprite positions
	cpSpaceEachShape(space, &forEachShape, nil);
}

@end
