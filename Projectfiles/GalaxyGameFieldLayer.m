    //
//  StreakLayer.h
//
//  Created by Oliver Widder
//  (Used a copy templayte from Steffen Itterheim (http://www.learn-cocos2d.com/store/book-learn-cocos2d/)
//

#import "GalaxyGameFieldLayer.h"
#import "GalaxyGameUiLayer.h"
#import "PointsLayer.h"
#import "GameManager.h"

#import "CGPointExtension.h"

#define GALAXY_SCENE_1_MUSIC_FILE_1 @"galaxy-scene-1.aifc"
#define GALAXY_SCENE_1_MUSIC_FILE_2 @"galaxy-scene-2.aifc"
#define GALAXY_SCENE_1_MUSIC_FILE_3 @"galaxy-scene-3.aifc"

#define GALAXY_SCENE_1_MUSIC_ATTRIBUTION_1 @"Music '43 Days' by Kemi Helwa (licensed under CC BY 3.0)"
#define GALAXY_SCENE_1_MUSIC_ATTRIBUTION_2 @"Music 'Dawn' by Beda (licensed under CC BY 3.0)"
#define GALAXY_SCENE_1_MUSIC_ATTRIBUTION_3 @"Music 'Black Hole' by Earthling (licensed under CC BY 3.0)"

#pragma mark constants

/**
 The increase of the force the galaxies apply on the player for each round
 */
static int GALAXY_PLAYER_FORCE_INCREASE = 20;

/**
 Number of seconds per round
 */
static int ROUND_LENGTH_IN_SECONDS = 60;

/**
 maximum distance points
 */
static int MAX_DISTANCE_POINTS = 200;

#pragma mark structs and classes etc.

// used for the explode method as user data
@interface NodeAndFilename : NSObject
@property(strong) CCNode *node;
@property(strong) NSString *filename;
@end

@implementation NodeAndFilename
@synthesize node;
@synthesize filename;
@end

/**
 Used as UserInfo for the 'forEachShape' method
 */
typedef struct {
    int distancePoints;
    cpBody *playerBody;
    int roundNumber;
    cpShape *nearestGalaxyShape;
} EachShapeData;

/**
 additional data for each body
 */
typedef struct {
    KindOfThing kindOfThing;
    void *node;
} ShapeInfo;

#pragma mark static fields

/**
 Gets YES when the playerBody collides with a galaxy
 */
static BOOL playerGalaxyCollisionHappened;

/**
 Gets YES when the playerBody collides with a border
 */
static BOOL playerBorderCollisionHappened;

/**
 Gets YES when the playerBody collides with the fingerTip
 */
static BOOL playerFingerTipCollisionHappened;

/**
 Default ShapeInfo for borders
 */
static ShapeInfo borderShapeInfo;

#pragma mark static helpers

static int distancePoints(float distance) {
    float roundedDistance = roundf(distance);
    float points = max(MAX_DISTANCE_POINTS - roundedDistance, 0);
    
    return (int) floor(points);
}

/**
 @return true if shapeInfoA has kindOfThing1 and shapeInfoB has kindOfThing2 or vice versa
 */
static BOOL areTheseKindOfThingsInvolved(ShapeInfo *shapeInfoA, ShapeInfo *shapeInfoB, KindOfThing kindOfThing1, KindOfThing kindOfThing2) {
    BOOL kindOfThing1IsInvolved = NO;
    BOOL kindOfThin2IsInvolved = NO;

    if(shapeInfoA != nil) {
        if(shapeInfoA->kindOfThing == kindOfThing1) {
            kindOfThing1IsInvolved = YES;
        }
        else if(shapeInfoA->kindOfThing == kindOfThing2) {
            kindOfThin2IsInvolved = YES;
        }
    }

    if(shapeInfoB != nil) {
        if(shapeInfoB->kindOfThing == kindOfThing1) {
            kindOfThing1IsInvolved = YES;
        }
        else if(shapeInfoB->kindOfThing == kindOfThing2) {
            kindOfThin2IsInvolved = YES;
        }
    }
    
    return (kindOfThing1IsInvolved && kindOfThin2IsInvolved);
}

#pragma mark C Callbacks

// C callback method that updates sprite position and rotation:
static void forEachShape(cpShape* shape, void* data)
{
    EachShapeData *eachShapeData = (EachShapeData*) data;
    
    if(shape != nil) {
        ShapeInfo *shapeInfo = (ShapeInfo*) shape->data;
        CCSprite* sprite = (__bridge CCSprite*)shapeInfo->node;
        if (sprite != nil) {
            cpBody* body = shape->body;
            sprite.position = body->p;
            //		sprite.rotation = CC_RADIANS_TO_DEGREES(body->a) * -1;
            
            // apply forces from each galaxy to the player
            // and calculate the distance points
            if(eachShapeData->playerBody != nil && shapeInfo->kindOfThing == kGalaxy) {
                float distance = ccpDistance(eachShapeData->playerBody->p, body->p);
                int dp = distancePoints(distance);
                if(dp > eachShapeData->distancePoints) {
                    eachShapeData->distancePoints = dp;
                    eachShapeData->nearestGalaxyShape = shape;
                }
                else {
                    CGPoint direction = ccpSub(body->p, eachShapeData->playerBody->p);
                    float f = (eachShapeData->roundNumber * GALAXY_PLAYER_FORCE_INCREASE) / (distance * distance);
                    cpBodyApplyForce(eachShapeData->playerBody, ccpMult(direction, f), CGPointMake(5.0, 5.0));
                }
            }
        }
    }
}

// C callback methods for collision handling
static int contactBegin(cpArbiter* arbiter, struct cpSpace* space, void* data)
{
	cpShape* shapeA;
	cpShape* shapeB;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    ShapeInfo *shapeInfoA = (ShapeInfo*) shapeA->data;
    ShapeInfo *shapeInfoB = (ShapeInfo*) shapeB->data;
    
    if(areTheseKindOfThingsInvolved(shapeInfoA, shapeInfoB, kPlayer, kGalaxy)) {
        playerGalaxyCollisionHappened = YES;
    }
    
	return YES;
}

static void contactEnd(cpArbiter* arbiter, cpSpace* space, void* data)
{
	cpShape* shapeA;
	cpShape* shapeB;
	cpArbiterGetShapes(arbiter, &shapeA, &shapeB);
    
    ShapeInfo *shapeInfoA = (ShapeInfo*) shapeA->data;
    ShapeInfo *shapeInfoB = (ShapeInfo*) shapeB->data;
    
    if(areTheseKindOfThingsInvolved(shapeInfoA, shapeInfoB, kPlayer, kBorder)) {
        playerBorderCollisionHappened = YES;
    }
    else if(areTheseKindOfThingsInvolved(shapeInfoA, shapeInfoB, kPlayer, kFingerTip)) {
        playerFingerTipCollisionHappened = YES;
    }
}

#pragma mark extension

@interface GalaxyGameFieldLayer ()
{
    // the chipmunk space
    cpSpace *space;
    
    // the static shape/node created by a finger tip
    cpShape *fingerTipShape;
    CCNode *fingerTipNode;
    cpBody *fingerTipBody;
    BOOL fingerTipSet;
    
    // transport data structure for the forEachShape function
    // reused for performance sake
    EachShapeData *eachShapeData;

    // when the game is in running mode
    // no new player can be created
    GameMode gameMode;
    
    // the one and only player at a time
    cpBody *playerBody;
    cpShape *playerShape;
    CCParticleSystem *playerNode;
    ShapeInfo playerShapeInfo;
    
    // start positions of the galaxies
    CGPoint redGalaxyStartPoint;
    CGPoint blueGalaxyStartPoint;
    CGPoint greenGalaxyStartPoint;
    CGPoint rgbGalaxyStartPoint;
    
    // the galaxies
    cpShape *redGalaxyShape;
    cpShape *blueGalaxyShape;
    cpShape *greenGalaxyShape;
    cpShape *rgbGalaxyShape;
    
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
    
    /**
     Remaining seconds in the current round
     */
    int remainingSeconds;
    
    /**
     Timer for the remaining seconds
     */
    NSTimer *remainingSecondsTimer;
    
    /**
     round data
     */
    int roundNumber;
    int roundPoints;
    int totalPoints;
    
    /**
     Array with songs, attributes and its current index
     */
    NSArray *songFiles;
    NSArray *attributeTexts;
    int currentSongIndex;
}

-(void) initField;
-(void) resetMotionStreak;
-(CCMotionStreak*) currentMotionStreak;
-(void) addNewPlayerAt:(CGPoint)pos withImpulse:(CGPoint)impulse;
-(CCParticleSystem*) addParticleSystemAt:(CGPoint)pos withFile:(NSString*)file;
-(void) moveMotionStreakToTouch:(UITouch*)touch;
-(CGPoint) locationFromTouch:(UITouch*)touch;
-(void) stopRoundWithIsLost:(BOOL)isLost;
-(void) explodeNode:(NSTimer*)timer;
-(void) removeNode:(NSTimer*)timer;
-(cpShape*) createGalaxyAtPosition:(CGPoint)position withFile:(NSString*)file;
-(void) startRound:(NSTimer*)timer;
-(void) startRoundWithDelay:(float)delay;
-(void) countDown:(NSTimer*)timer;

-(void) updateRoundPoints:(int)p;
-(void) updateTotalPoints:(int)p;
-(void) updateRoundNumber:(int)rn;
-(void) updateRemainingSeconds:(int)rs;

-(void) initMusic;
-(void) playMusic;

-(BOOL) isInFreeSpace:(CGPoint)pos withFreeSpaceSize:(int)size;
-(void) setFingerTipShape:(CGPoint)pos;
-(void) clearFingerTipShape;
-(void) moveFingerTipShape:(CGPoint)pos;

-(void) showDistancePoints:(int)points atGalaxy:(cpShape*)galaxyShape;
@end

@implementation GalaxyGameFieldLayer

#pragma mark NSObject

-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    cpSpaceFree(space);
    free(eachShapeData);
    free(redGalaxyShape->data);
    free(blueGalaxyShape->data);
    free(greenGalaxyShape->data);
    free(rgbGalaxyShape->data);
#ifndef KK_ARC_ENABLED
	[super dealloc];
#endif
}

#pragma mark GalaxyGameFieldLayer

-(id) initWithUiLayer:(GalaxyGameUiLayer *)pUiLayer andPointsLayer:(PointsLayer *)pPointsLayer
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    if(self = [super init]) {
        eachShapeData = malloc(sizeof(EachShapeData));
        uiLayer = pUiLayer;
        pointsLayer = pPointsLayer;
        [self initField];
        [self initMusic];
        [self playMusic];
    }
    
    return self;
}

#pragma mark private methods

-(void) initMusic
{
    songFiles = [NSArray arrayWithObjects:GALAXY_SCENE_1_MUSIC_FILE_1, GALAXY_SCENE_1_MUSIC_FILE_2, GALAXY_SCENE_1_MUSIC_FILE_3, nil];
    attributeTexts = [NSArray arrayWithObjects:GALAXY_SCENE_1_MUSIC_ATTRIBUTION_1, GALAXY_SCENE_1_MUSIC_ATTRIBUTION_2, GALAXY_SCENE_1_MUSIC_ATTRIBUTION_3, nil];
    currentSongIndex = arc4random() % [songFiles count];
    
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    [[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:YES];
    soundEngine = [SimpleAudioEngine sharedEngine];
    
    [[CDAudioManager sharedManager] setBackgroundMusicCompletionListener:self selector:@selector(playMusic)];
}

/**
 Start the background music
 */
-(void) playMusic
{
    NSString *songFile = [songFiles objectAtIndex:currentSongIndex];
    [soundEngine preloadBackgroundMusic:songFile];
    [soundEngine playBackgroundMusic:songFile];

    NSString *attribution = [attributeTexts objectAtIndex:currentSongIndex];
    attributionLabel.string = attribution;
    
    currentSongIndex++;
    if(currentSongIndex >= (int)[songFiles count]){
        currentSongIndex = 0;
    }
}

/**
 Init the playing field
 */
-(void) initField
{
    CGSize screenSize = [CCDirector sharedDirector].winSize;

    // new game button
    CCLabelTTF *newGameButtonLabel = [CCLabelTTF labelWithString:@"New Game" fontName:@"Chalkduster" fontSize:20];

    newGameMenuItem = [CCMenuItemLabel itemWithLabel:newGameButtonLabel target:self selector:@selector(newGame)];
    newGameMenuItem.position = ccp(screenSize.width-100, screenSize.height-70);
    CCMenu *menu = [CCMenu menuWithItems:newGameMenuItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    touchStart = CGPointZero;
    
    space = cpSpaceNew();
    space->iterations = 8;
    //		space->gravity = CGPointMake(0, -200);
    
    // Add the collision handlers
    unsigned int defaultCollisionType = 0;
    cpSpaceAddCollisionHandler(space, defaultCollisionType, defaultCollisionType, &contactBegin, NULL, NULL, &contactEnd, NULL);
    
    // for the ground body we'll need these values
    float radius = 100.0f;
    CGPoint lowerLeftCorner = CGPointMake(-radius, -radius);
    CGPoint lowerRightCorner = CGPointMake(screenSize.width+radius, -radius);
    CGPoint upperLeftCorner = CGPointMake(-radius, screenSize.height+radius);
    CGPoint upperRightCorner = CGPointMake(screenSize.width+radius, screenSize.height+radius);
    
    // Create the static body that keeps objects within the screen area
    float mass = INFINITY;
    float inertia = INFINITY;
    cpBody* staticBody = cpBodyNew(mass, inertia);
    
    cpShape* shape;
    float elasticity = 1.0f;
    float friction = 1.0f;
    
    borderShapeInfo.kindOfThing = kBorder;
    
    // bottom
    shape = cpSegmentShapeNew(staticBody, lowerLeftCorner, lowerRightCorner, radius);
    shape->e = elasticity;
    shape->u = friction;
    shape->data = &borderShapeInfo;
    cpSpaceAddStaticShape(space, shape);
    
    // top
    shape = cpSegmentShapeNew(staticBody, upperLeftCorner, upperRightCorner, radius);
    shape->e = elasticity;
    shape->u = friction;
    shape->data = &borderShapeInfo;
    cpSpaceAddStaticShape(space, shape);
    
    // left
    shape = cpSegmentShapeNew(staticBody, lowerLeftCorner, upperLeftCorner, radius);
    shape->e = elasticity;
    shape->u = friction;
    shape->data = &borderShapeInfo;
    cpSpaceAddStaticShape(space, shape);
    
    // right
    shape = cpSegmentShapeNew(staticBody, lowerRightCorner, upperRightCorner, radius);
    shape->e = elasticity;
    shape->u = friction;
    shape->data = &borderShapeInfo;
    cpSpaceAddStaticShape(space, shape);
    
    rgbGalaxyStartPoint = ccp(screenSize.width/2, screenSize.height/2);
    redGalaxyStartPoint = ccp(screenSize.width/2, screenSize.height-50);
    greenGalaxyStartPoint = ccp(screenSize.width-50, 50);
    blueGalaxyStartPoint = ccp(50, 50);
    
    blueGalaxyShape = [self createGalaxyAtPosition:blueGalaxyStartPoint withFile:@"blueGalaxy.plist"];
    redGalaxyShape = [self createGalaxyAtPosition:redGalaxyStartPoint withFile:@"redGalaxy3.plist"];
    greenGalaxyShape = [self createGalaxyAtPosition:greenGalaxyStartPoint withFile:@"greenGalaxy.plist"];
    rgbGalaxyShape = [self createGalaxyAtPosition:rgbGalaxyStartPoint withFile:@"rgbGalaxy.plist"];
    
    //		[KKInput sharedInput].accelerometerActive = YES;
    
    gameMode = kNotStarted;
    playerGalaxyCollisionHappened = NO;
    
    attributionLabel =  [CCLabelTTF labelWithString:@"" fontName:@"AmericanTypewriter-Bold" fontSize:10];
    attributionLabel.anchorPoint = ccp(0, 0);
    attributionLabel.position = ccp(10, 10);
    [self addChild:attributionLabel];
    
    self.isTouchEnabled = YES;
    [self resetMotionStreak];
    [self scheduleUpdate];
    
    fingerTipShape = nil;
    fingerTipBody = nil;
    fingerTipNode = nil;
    fingerTipSet = NO;
    
    [self startGame];
}

-(void) showMenu
{
    CGSize winsize = [CCDirector sharedDirector].screenSize;
    
    CCLabelTTF *startGameButtonLabel = [CCLabelTTF labelWithString:@"New Game" fontName:@"Chalkduster" fontSize:20];
    
    newGameMenuItem = [CCMenuItemLabel itemWithLabel:startGameButtonLabel target:self selector:@selector(newGame)];
    newGameMenuItem.position = ccp(20, winsize.height-100);
    CCMenu *menu = [CCMenu menuWithItems:newGameMenuItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
}

/**
 Create a galaxy at the given position and with a particle plist file with the given name
 */
-(cpShape*) createGalaxyAtPosition:(CGPoint)position withFile:(NSString*)file
{
	float mass = 200.0f;
	float moment = cpMomentForCircle(mass, 10, 10, CGPointZero);
	cpBody *galaxyBody = cpBodyNew(mass, moment);
	
	galaxyBody->p = position;
	cpSpaceAddBody(space, galaxyBody);
    
	float elasticity = 1.0f;
	float friction = 1.0f;
	
    cpShape *galaxyShape = cpCircleShapeNew(galaxyBody, 10, CGPointZero);
	galaxyShape->e = elasticity;
	galaxyShape->u = friction;
    
    // ShapeInfo
    ShapeInfo *galaxyShapeInfo = malloc(sizeof(ShapeInfo));
    galaxyShapeInfo->kindOfThing = kGalaxy;
    CCNode *galaxyNode = [self addParticleSystemAt:position withFile:file];
    galaxyShapeInfo->node = (__bridge void*)galaxyNode;
	galaxyShape->data = galaxyShapeInfo;
    
	cpSpaceAddShape(space, galaxyShape);
    
    return galaxyShape;
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
    
    if(nodeAndFilename.node != nil) {
        CCParticleSystemQuad *explosion;
        explosion = [CCParticleSystemQuad particleWithFile:nodeAndFilename.filename];
        explosion.position = nodeAndFilename.node.position;
        [self removeChild:nodeAndFilename.node cleanup:YES];
        [self addChild:explosion];
        
        [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(removeNode:) userInfo:explosion repeats:NO];
    }
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
	
	float elasticity = 0.9f;
	float friction = 0.9f;
	
    playerShape = cpCircleShapeNew(playerBody, 10, CGPointZero);
	playerShape->e = elasticity;
	playerShape->u = friction;
        
    playerNode = [self addParticleSystemAt:pos withFile:@"player.plist"];
    playerShapeInfo.kindOfThing = kPlayer;
    playerShapeInfo.node = (__bridge void*)playerNode;
	playerShape->data = &playerShapeInfo;
	cpSpaceAddShape(space, playerShape);
    
    cpBodyApplyImpulse(playerBody, impulse, CGPointZero);
    
    gameMode = kRunning;
    
    remainingSecondsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
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

/**
 Returns YES if in a 'size' radius ariund 'pos' is no galaxy or player (regarding it's position)
 */
-(BOOL) isInFreeSpace:(CGPoint)pos withFreeSpaceSize:(int)size
{
    BOOL itIs = YES;
    
    int distanceToPlayer = ccpDistance(pos, playerBody->p);
    if(distanceToPlayer < size) {
        itIs = NO;
    }
    
    int distanceToRedGalaxy = ccpDistance(pos, redGalaxyShape->body->p);
    if(distanceToRedGalaxy < size) {
        itIs = NO;
    }
    
    int distanceToGreenGalaxy = ccpDistance(pos, greenGalaxyShape->body->p);
    if(distanceToGreenGalaxy < size) {
        itIs = NO;
    }
    
    int distanceToBlueGalaxy = ccpDistance(pos, blueGalaxyShape->body->p);
    if(distanceToBlueGalaxy < size) {
        itIs = NO;
    }
    
    int distanceToRgbGalaxy = ccpDistance(pos, rgbGalaxyShape->body->p);
    if(distanceToRgbGalaxy < 15) {
        itIs = NO;
    }
    
    return itIs;
}

#pragma mark fingerTip handling

/**
 Set a static shape at the given poition
 */
-(void) setFingerTipShape:(CGPoint)pos
{
	fingerTipBody = cpBodyNew(INFINITY, INFINITY);
	fingerTipBody->p = pos;
	cpSpaceAddBody(space, fingerTipBody);
    
    fingerTipShape = cpCircleShapeNew(fingerTipBody, 3, CGPointZero);
	fingerTipShape->e = 1.0f;
	fingerTipShape->u = 1.0f;
    
    // ShapeInfo
    ShapeInfo *fingerTipShapeInfo = malloc(sizeof(ShapeInfo));
    fingerTipShapeInfo->kindOfThing = kFingerTip;
    fingerTipNode = [self addParticleSystemAt:pos withFile:@"fingertip2.plist"];
    fingerTipShapeInfo->node = (__bridge void*)fingerTipNode;
	fingerTipShape->data = fingerTipShapeInfo;
    
	cpSpaceAddShape(space, fingerTipShape);
    
    fingerTipSet = YES;
}

-(void) clearFingerTipShape
{
    if(fingerTipSet) {
        if(fingerTipShape != nil) {
            cpSpaceRemoveShape(space, fingerTipShape);
            cpShapeFree(fingerTipShape);
            fingerTipShape =nil;
        }
        if(fingerTipBody != nil) {
            cpSpaceRemoveBody(space, fingerTipBody);
            cpBodyFree(fingerTipBody);
            fingerTipBody = nil;
        }
        if(fingerTipNode != nil) {
            [self removeChild:fingerTipNode cleanup:YES];
            fingerTipNode = nil;
        }
        fingerTipSet = NO;
    }
}

-(void) moveFingerTipShape:(CGPoint)pos
{
    if(fingerTipSet && fingerTipBody != nil) {
        fingerTipBody->p = pos;
    }
//    [self clearFingerTipShape];
//    [self setFingerTipShape:pos];
}

#pragma mark update the labels

-(void) updateRoundNumber:(int)rn
{
    roundNumber = rn;
    [uiLayer displayRound:rn];
}

-(void) updateRoundPoints:(int)p
{
    roundPoints = p;
    [uiLayer displayRoundPoints:p];
}

-(void) updateTotalPoints:(int)p
{
    totalPoints = p;
    [uiLayer displayTotalPoints:p];
}

-(void) updateRemainingSeconds:(int)rs
{
    if(rs >= 0) {
        remainingSeconds = rs;
        [uiLayer displayTime:rs];
    }
}

/**
 Show the current distance points at the galaxy responsible for the points
 */
-(void) showDistancePoints:(int)points atGalaxy:(cpShape*)galaxyShape
{
    CGPoint galaxyPos = galaxyShape->body->p;
    CGPoint labelPos = CGPointMake(galaxyPos.x + 30, galaxyPos.y - 30);
    
    if(galaxyShape == redGalaxyShape) {
        [pointsLayer showRedGalaxyPoints:points atPosition:labelPos];
    }
    else if(galaxyShape == greenGalaxyShape) {
        [pointsLayer showGreenGalaxyPoints:points atPosition:labelPos];
    }
    else if(galaxyShape == blueGalaxyShape) {
        [pointsLayer showBlueGalaxyPoints:points atPosition:labelPos];
    }
    else if(galaxyShape == rgbGalaxyShape) {
        [pointsLayer showRgbGalaxyPoints:points atPosition:labelPos];
    }
}

#pragma mark Round and Game Handling

-(void) startGame
{
    [self updateTotalPoints:0];
    [self updateRoundNumber:0];
    [self startRound:nil];
}

-(void) newGame
{
    [GameManager startIntro];
    
//    [self stopRound];
//
//    cpBodySetVel(redGalaxy, ccp(0, 0));
//    cpBodySetVel(blueGalaxy, ccp(0, 0));
//    cpBodySetVel(greenGalaxy, ccp(0, 0));
//    cpBodySetVel(rgbGalaxy, ccp(0, 0));
//    
//    redGalaxy->p = redGalaxyStartPoint;
//    blueGalaxy->p = blueGalaxyStartPoint;
//    greenGalaxy->p = greenGalaxyStartPoint;
//    rgbGalaxy->p = rgbGalaxyStartPoint;
//    
//    [self startGame];
}

-(void) countDown:(NSTimer *)timer
{
    [self updateRemainingSeconds:--remainingSeconds];
    if(remainingSeconds == 0) {
        [timer invalidate];
        [self updateTotalPoints:totalPoints + roundPoints];
        gameMode = kRoundEnded;
    }
}

/**
 Stop the running mode:
 - Remove the player (with an explosion)
 - Use different particle effects dependant on isLost
 */
-(void) stopRoundWithIsLost:(BOOL)isLost {
    [pointsLayer hideAllLabels];
    if(isLost) {
        [pointsLayer lose];
    }
    else {
        [pointsLayer win];
    }
    
    if(playerShape != nil) {
        cpSpaceRemoveShape(space, playerShape);
        cpShapeFree(playerShape);
    }
    if(playerBody != nil) {
        cpSpaceRemoveBody(space, playerBody);
        cpBodyFree(playerBody);
    }
    
    playerBody = nil;
    playerShape = nil;
    
    NodeAndFilename *userInfo = [[NodeAndFilename alloc] init];
    userInfo.node = playerNode;
    playerNode = nil;
    float waitTime = 1.0;
    if(isLost) {
        userInfo.filename = @"bang.plist";
        waitTime = 0.1;
    }
    else {
        userInfo.filename = @"explode.plist";
        waitTime = 0.1;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:waitTime target:self selector:@selector(explodeNode:) userInfo:userInfo repeats:NO];
}

-(void) startRoundWithDelay:(float)delay
{
    [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(startRound:) userInfo:nil repeats:NO];
}

-(void) startRound:(NSTimer*)timer
{
    [timer invalidate];
    
    [self updateRoundPoints:0];
    [self updateRoundNumber:++roundNumber];
    [self updateRemainingSeconds:ROUND_LENGTH_IN_SECONDS];

    gameMode = kIdle;
    
    CCParticleSystemQuad *newRoundPS;
    newRoundPS = [CCParticleSystemQuad particleWithFile:@"newRound.plist"];
    CGSize winSize = [CCDirector sharedDirector].screenSize;
    newRoundPS.position = ccp(winSize.width/2, winSize.height/2);
    [self addChild:newRoundPS];

    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(removeNode:) userInfo:newRoundPS repeats:NO];
    
    if(remainingSecondsTimer) {
        [remainingSecondsTimer invalidate];
    }
    
    eachShapeData->roundNumber = roundNumber;
    eachShapeData->nearestGalaxyShape = nil;
    eachShapeData->distancePoints = 0;
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
    
    if(gameMode == kRunning) {
        [self setFingerTipShape:[self locationFromTouch:touch]];
    }
	
	// Always swallow touches.
	return YES;
}

-(void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent *)event
{
	[self moveMotionStreakToTouch:touch];
    if(gameMode == kRunning) {
        [self moveFingerTipShape:[self locationFromTouch:touch]];
    }
}

-(void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent *)event
{
    [self resetMotionStreak];
    [self clearFingerTipShape];

    if(gameMode == kIdle) {
        CGPoint touchEnd = [self locationFromTouch:touch];
        CGPoint delta = ccpSub(touchEnd, touchStart);
        
        NSTimeInterval endTime = event.timestamp;
        double deltaTime = endTime - startTime;
        
        float force = (1 / deltaTime) * 2;
        
        CGPoint impulse = ccpMult(delta, force);
        [self addNewPlayerAt:touchEnd withImpulse:impulse];
        
//        CGPoint endpos = ccpAdd(touchEnd, impulse);
//        CGSize screenSize = [CCDirector sharedDirector].winSize;
//        if(endpos.x > 0 && endpos.x < screenSize.width && endpos.y > 0 && endpos.y < screenSize.height) {
//        }
    }
}

#pragma mark CCNode

-(void) update:(ccTime)delta
{
    if(gameMode == kRunning && playerBody != nil) {
        if(detectionCounter++ == 10) {
            detectionCounter = 0;
            lastPlayerPosition = playerBody->p;
        }
    }
    else if(gameMode == kRoundEnded) {
        gameMode = kNotStarted;
        [self stopRoundWithIsLost:NO];
        [self startRoundWithDelay:1.0];
    }
    
	float timeStep = 0.03f;
	cpSpaceStep(space, timeStep);
	
	// call forEachShape C method to update sprite positions
    // and to compute the min distance
    
    eachShapeData->playerBody = playerBody;
    cpSpaceEachShape(space, &forEachShape, eachShapeData);

    if(playerGalaxyCollisionHappened) {
        playerGalaxyCollisionHappened = NO;
        [self stopRoundWithIsLost:YES];
        [self startRoundWithDelay:1.0];
    }
    
    if(playerBorderCollisionHappened) {
        playerBorderCollisionHappened = NO;
        [self updateRoundPoints:roundPoints + eachShapeData->distancePoints];
        [pointsLayer hideCurrentGalaxyLabel];
        [pointsLayer showRoundPoints:eachShapeData->distancePoints atPosition:playerBody->p];
        eachShapeData->distancePoints = 0;
    }
    
    if(playerFingerTipCollisionHappened) {
        playerFingerTipCollisionHappened = NO;
        cpVect vel = cpBodyGetVel(playerBody);
        cpBodySetVel(playerBody, ccp(vel.x*2, vel.y*2));
    }
    
    if(eachShapeData->nearestGalaxyShape != nil) {
        [self showDistancePoints:eachShapeData->distancePoints atGalaxy:eachShapeData->nearestGalaxyShape];
    }
}

@end
