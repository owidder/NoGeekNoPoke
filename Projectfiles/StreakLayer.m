//
//  StreakLayer.h
//
//  Created by Oliver Widder
//  (Used a copy templayte from Steffen Itterheim (http://www.learn-cocos2d.com/store/book-learn-cocos2d/)
//

#import "StreakLayer.h"

#import "CGPointExtension.h"

#pragma mark NodeAndFilename

// used for the explode method as user data
@interface NodeAndFilename : NSObject
@property(strong) CCNode *node;
@property(strong) NSString *filename;
@end

@implementation NodeAndFilename
@synthesize node = _node;
@synthesize filename = _filename;
@end

// when the game is in running mode
// no new player can be created
static GameMode gameMode;

// C callback method that updates sprite position and rotation:
static void forEachShape(cpShape* shape, void* data)
{
    cpBody *playerBody = (cpBody*) data;
    
    if(shape != nil) {
        CCSprite* sprite = (__bridge CCSprite*)shape->data;
        if (sprite != nil) {
            cpBody* body = shape->body;
            sprite.position = body->p;
            //		sprite.rotation = CC_RADIANS_TO_DEGREES(body->a) * -1;
            
            // apply forces from each galaxy to the player
            if(playerBody != nil && body != nil && body != playerBody) {
                float distance = ccpDistance(playerBody->p, body->p);
                if(distance < 10) {
                    gameMode = kLost;
                }
                else {
                    CGPoint direction = ccpSub(body->p, playerBody->p);
                    float f = 200 / (distance * distance);
                    cpBodyApplyForce(playerBody, ccpMult(direction, f), CGPointMake(5.0, 5.0));
                }
            }
        }
    }
}

@interface StreakLayer ()
{
    // the one and only player at a time
    cpBody *playerBody;
    cpShape *playerShape;
    CCParticleSystem *playerNode;
    
    // the last players position to detect
    // whether has has moved since
    CGPoint lastPlayerPosition;
    
    // needed to detect, whether the player has moved
    // only checked, when the counter has reached a certain number
    // e.g.: check every second: number = 60
    int detectionCounter;
    
    // the position where a touch has started
    CGPoint touchStart;
    
    // the time when a touch has started
    NSTimeInterval startTime;    
}

-(void) resetMotionStreak;
-(CCMotionStreak*) currentMotionStreak;
-(void) addNewPlayerAt:(CGPoint)pos withImpulse:(CGPoint)impulse;
-(CCParticleSystem*) addParticleSystemAt:(CGPoint)pos withFile:(NSString*)file;
-(void) moveMotionStreakToTouch:(UITouch*)touch;
-(CGPoint) locationFromTouch:(UITouch*)touch;
-(void) stopRunningMode;
-(void) createGalaxyAtPosition:(CGPoint)position withFile:(NSString*)file;
-(void) explodeNode:(NSTimer*)timer;
-(void) removeNode:(NSTimer*)timer;
-(void) createGalaxyAtPosition:(CGPoint)position withFile:(NSString*)file;
@end

@implementation StreakLayer

#pragma mark -
#pragma mark static helper methods

/**
 Create a CCScene and add this layer as a child
 */
+(id) scene
{
	CCScene* scene = [CCScene node];
	StreakLayer* layer = [StreakLayer node];
	[scene addChild:layer];
	return scene;
}

#pragma mark NSObject

-(id) init
{
	if ((self = [super init]))
	{
        touchStart = CGPointZero;
        
		space = cpSpaceNew();
		space->iterations = 8;
//		space->gravity = CGPointMake(0, -200);
		
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
        
        [self createGalaxyAtPosition:CGPointMake(screenSize.width/2, screenSize.height/2) withFile:@"blueGalaxy.plist"];
        [self createGalaxyAtPosition:CGPointMake(screenSize.width/2-200, screenSize.height/2-200) withFile:@"redGalaxy.plist"];
        [self createGalaxyAtPosition:CGPointMake(screenSize.width/2+200, screenSize.height/2-200) withFile:@"greenGalaxy.plist"];
		
//		[KKInput sharedInput].accelerometerActive = YES;
        
        gameMode = kIdle;
        
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

#pragma mark private methods

/**
 Create a galaxy at the given position and with a particle plist file with the given name
 */
-(void) createGalaxyAtPosition:(CGPoint)position withFile:(NSString*)file
{
	float mass = 200.0f;
	float moment = cpMomentForCircle(mass, 3, 3, CGPointZero);
	cpBody *galaxyBody = cpBodyNew(mass, moment);
	
	galaxyBody->p = position;
	cpSpaceAddBody(space, galaxyBody);
	
	float elasticity = 1.0f;
	float friction = 1.0f;
	
    cpShape *galaxyShape = cpCircleShapeNew(galaxyBody, 3, CGPointZero);
	galaxyShape->e = elasticity;
	galaxyShape->u = friction;
    
    
    CCNode *galaxyNode = [self addParticleSystemAt:position withFile:file];
	galaxyShape->data = (__bridge void*)galaxyNode;
    
	cpSpaceAddShape(space, galaxyShape);
}

/**
 Remove the node given as userdata
 */
-(void) removeNode:(NSTimer*)timer
{
    CCNode *node = (CCNode*) timer.userInfo;
    [self removeChild:node cleanup:YES];
    [timer invalidate];
}

/**
 Do an explosion of the position of the node which is in the user info of the given timer
 The explosin type depends on the gameMode (idle or lost)
 */
-(void) explodeNode:(NSTimer*)timer;
{
    NodeAndFilename *nodeAndFilename = (NodeAndFilename*) timer.userInfo;
    CCParticleSystemQuad *explosion;
    explosion = [CCParticleSystemQuad particleWithFile:nodeAndFilename.filename];
    explosion.position = nodeAndFilename.node.position;
    [self removeChild:nodeAndFilename.node cleanup:YES];
    [self addChild:explosion];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(removeNode:) userInfo:explosion repeats:NO];
}

/**
 Stop the running mode:
 - Remove the player (with an explosion)
 */
-(void) stopRunningMode {
    cpSpaceRemoveShape(space, playerShape);
    cpSpaceRemoveBody(space, playerBody);
    cpShapeFree(playerShape);
    cpBodyFree(playerBody);
    
    playerBody = nil;
    playerShape = nil;
    
    NodeAndFilename *userInfo = [[NodeAndFilename alloc] init];
    userInfo.node = playerNode;
    if(gameMode == kLost) {
        userInfo.filename = @"bang.plist";
    }
    else {
        userInfo.filename = @"explode.plist";
    }
    
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(explodeNode:) userInfo:userInfo repeats:NO];
    
    gameMode = kIdle;
}

/**
 Add a new 'player.plist' partice system at the given position
 */
-(CCParticleSystem*) addParticleSystemAt:(CGPoint)pos withFile:(NSString*)file
{
    CCParticleSystemQuad *psq = [CCParticleSystemQuad particleWithFile:file];
    psq.position = pos;
    
    [self addChild:psq z:0 tag:kTagPlayer];
    
    return psq;
}

/**
 Kill the current and create a new CCMotionStreak
 */
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

/**
 Create a new player at the given position and immediately apply the given force
 */
-(void) addNewPlayerAt:(CGPoint)pos withImpulse:(CGPoint)impulse
{
	float mass = 5.5f;
	float moment = cpMomentForCircle(mass, 10, 10, CGPointZero);
	playerBody = cpBodyNew(mass, moment);
	
    lastPlayerPosition = pos;
    detectionCounter = 0;
    
	playerBody->p = pos;
	cpSpaceAddBody(space, playerBody);
	
	float elasticity = 0.5f;
	float friction = 0.2f;
	
    playerShape = cpCircleShapeNew(playerBody, 10, CGPointZero);
	playerShape->e = elasticity;
	playerShape->u = friction;
    
    playerNode = [self addParticleSystemAt:pos withFile:@"player.plist"];
	playerShape->data = (__bridge void*)playerNode;
	cpSpaceAddShape(space, playerShape);
    
    cpBodyApplyImpulse(playerBody, impulse, CGPointMake(5, 5));
    
    gameMode = kRunning;
}

/**
 get the current CCMotionStreak
 */
-(CCMotionStreak*) currentMotionStreak
{
	CCNode* node = [self getChildByTag:kTagMotionStreak];
	NSAssert([node isKindOfClass:[CCMotionStreak class]], @"node is not a CCMotionStreak");
	
	return (CCMotionStreak*)node;
}

/**
 Move the current CCMotionStreak to the position of the given UITouch
 */
-(void) moveMotionStreakToTouch:(UITouch*)touch
{
	CCMotionStreak* streak = [self currentMotionStreak];
	streak.position = [self locationFromTouch:touch];
}

/**
 Get the position of the given UITouch
 */
-(CGPoint) locationFromTouch:(UITouch*)touch
{
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

#pragma mark Touch Handling

-(void) registerWithTouchDispatcher
{
	[[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent *)event
{
    [self resetMotionStreak];
	[self moveMotionStreakToTouch:touch];
    
    touchStart = [self locationFromTouch:touch];
    startTime = event.timestamp;
	
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

    if(gameMode == kIdle) {
        CGPoint touchEnd = [self locationFromTouch:touch];
        
        float distance = ccpDistance(touchEnd, touchStart);
        if(distance < 100) {
            CGPoint delta = ccpSub(touchEnd, touchStart);
            
            NSTimeInterval endTime = event.timestamp;
            double deltaTime = endTime - startTime;
            
            float force = max((1 / deltaTime), 5) * 2;
            
            CGPoint impulse = ccpMult(delta, force);
            
            [self addNewPlayerAt:[self locationFromTouch:touch] withImpulse:impulse];
        }        
    }
}

#pragma mark CCNode

-(void) update:(ccTime)delta
{
    BOOL playerStopped = NO;
    
    if(gameMode == kLost) {
        [self stopRunningMode];
    }
    else if(gameMode == kRunning && playerBody != nil) {
        if(detectionCounter++ == 10) {
            detectionCounter = 0;
            int deltaX = abs(lastPlayerPosition.x - playerBody->p.x);
            int deltaY = abs(lastPlayerPosition.y - playerBody->p.y);
            if(deltaX < 10 && deltaY < 10) {
                [self stopRunningMode];
                playerStopped = YES;
            }
            else {
                lastPlayerPosition = playerBody->p;
            }
        }
    }
    
	float timeStep = 0.03f;
	cpSpaceStep(space, timeStep);
	
	// call forEachShape C method to update sprite positions
    cpSpaceEachShape(space, &forEachShape, playerBody);
}

@end
