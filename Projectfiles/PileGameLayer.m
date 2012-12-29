//
//  PileGameLayer.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 12/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PileGameLayer.h"
#import "GCpShapeCache.h"
#import "NodeUtil.h"

#define kAccelerationFilterFactor 0.05f

#undef WITH_ACCELERATION

#pragma mark enums

enum {
	kTagBatchNode = 1,
};

#pragma mark structs

// used for data exchange with the testBodyForTouchPosition callback
typedef struct {
    // the current touch location is inside this body
    cpBody *touchedBody;
    CGPoint touchLocation;
} TouchDetectionStruct;

#pragma mark static data

NSString *itemNames[] = {
    @"cat_rs",
    @"ball_rs",
    @"ball_rs",
    @"ball_rs",
    @"ball_rs",
    @"ball_rs",
    @"ball_rs",
    @"ball_rs"
};

#pragma mark C Callbacks

// callback during step
static void eachBody(cpBody *body, void *data) {
    BodyData *bd = (BodyData*)body->data;
	CCSprite *sprite = (__bridge CCSprite*) bd->sprite;
	if(sprite) {
		[sprite setPosition: body->p];
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

// search for the body the current touch location is in
// the found body is put into data->touchedBody
static void testBodyForTouchLocation(cpBody *body, void *data) {
    BodyData *bd = body->data;
	CCSprite *sprite = (__bridge CCSprite*) bd->sprite;
    TouchDetectionStruct *tds = (TouchDetectionStruct*)data;
	if(sprite) {
        if(CGRectContainsPoint(sprite.boundingBox, tds->touchLocation)) {
            tds->touchedBody = body;
        }
	}
}

#pragma mark extension

@interface PileGameLayer ()
{
    // timer for the creation of the items at the beginning
    NSTimer *itemTimer;
    
    // body to remove during the next step
    cpBody *bodyToRemove;
    
    // the current chipmunk space
    cpSpace *space;
    
    // for some node related useful stuff
    NodeUtil *nodeUtil;
}

-(void)step:(ccTime)dt;
-(void)addNewSpriteAtX:(float)x andY:(float)y withName:(NSString*)name;
-(void)nextItem;
-(cpBody*)touchedBody:(CGPoint)touchLocation;

@end

#pragma mark implementation

@implementation PileGameLayer

#pragma mark class methods

+(id)scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	PileGameLayer *layer = [PileGameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

#pragma mark NSObject

-(void)dealloc {
    cpSpaceFree(space);
    nodeUtil = nil;
}

-(id)init
{
	if( (self=[super init])) {
        
        bodyToRemove = nil;
        nodeUtil = [[NodeUtil alloc] init];
		
		self.isTouchEnabled = YES;
		self.isAccelerometerEnabled = YES;
		
		CGSize wins = [[CCDirector sharedDirector] winSize];
		cpInitChipmunk();
		
		cpBody *staticBody = cpBodyNew(INFINITY, INFINITY);
		space = cpSpaceNew();
		
		space->gravity = ccp(0, -900);
		
		cpShape *shape;
		
		// bottom
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(wins.width,0), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// top
		shape = cpSegmentShapeNew(staticBody, ccp(0,wins.height), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// left
		shape = cpSegmentShapeNew(staticBody, ccp(0,0), ccp(0,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
		// right
		shape = cpSegmentShapeNew(staticBody, ccp(wins.width,0), ccp(wins.width,wins.height), 0.0f);
		shape->e = 1.0f; shape->u = 1.0f;
		cpSpaceAddStaticShape(space, shape);
		
        // load physics data
        //        [[GCpShapeCache sharedShapeCache] addShapesWithFile:@"shapedefs.plist"];
        [[GCpShapeCache sharedShapeCache] addShapesWithFile:@"icons.plist"];
        
		[self schedule:@selector(step:)];
        
        itemTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(nextItem) userInfo:nil repeats:YES];
	}
	
	return self;
}

#pragma mark CCLayer

-(void)onEnter
{
	[super onEnter];
	
#ifdef WITH_ACCELERATION
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
#endif
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		location = [[CCDirector sharedDirector] convertToGL:location];
        cpBody *touchedBody = [self touchedBody:location];
        if(touchedBody) {
            bodyToRemove = touchedBody;
            BodyData *bd = touchedBody->data;
            if(bd && bd->sprite) {
                [nodeUtil shrinkAndExplodeNode:(__bridge CCNode *)(bd->sprite) ofLayer:self withExplosionPlistFilename:@"puff.plist"];
            }
        }
		
//        [self addNewSprite: location.x y:location.y];
	}
}

#ifdef WITH_ACCELERATION
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	static float prevX=0, prevY=0;
		
	float accelX = (float) acceleration.x * kFilterFactor + (1- kAccelerationFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kAccelerationFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	CGPoint v = ccp( -accelY, accelX );
	
	space->gravity = ccpMult(v, 200);
}
#endif


#pragma mark private methods

-(cpBody*)touchedBody:(CGPoint)touchLocation {
    cpBody *body = nil;
    
    TouchDetectionStruct *tds = malloc(sizeof(TouchDetectionStruct));
    tds->touchedBody = nil;
    tds->touchLocation = touchLocation;
    cpSpaceEachBody(space, &testBodyForTouchLocation, tds);
    body = tds->touchedBody;
    free(tds);
    
    return body;
}

-(void) step:(ccTime)delta {
    // we do not secure this with a semaphore
    // there may be weird edge cases, where bodyToRemove is
    // changed during the run of this method
    // To mitigate this, we copy the bodyToRemove in a local variable
    
    cpBody *localBodyToRemove = bodyToRemove;
    bodyToRemove = nil;

	int steps = 2;
	CGFloat dt = delta/(CGFloat)steps;
	
	for(int i=0; i<steps; i++) {
		cpSpaceStep(space, dt);
	}
    cpSpaceEachBody(space, &eachBody, nil);
    
    if(localBodyToRemove) {
        cpSpaceLock(space); {
            BodyData *bd = (BodyData*)localBodyToRemove->data;
            if(bd && bd->shape) {
                cpSpaceRemoveShape(space, bd->shape);
                cpShapeFree(bd->shape);
            }
            cpSpaceRemoveBody(space, localBodyToRemove);
            cpBodyFree(localBodyToRemove);
        }
    }
}

-(void)nextItem {
    static int ctr = 0;
    
    CGSize wins = [[CCDirector sharedDirector] winSize];
    
    int x = rand()%(int)(wins.width);
    int y = rand()%300 + 500;
    
    ctr++;
    
    if(ctr < 50) {
        [self addNewSpriteAtX:x andY:y withName:@"ball_rs"];
    }
    else {
        int t = rand()%10;
        if(t == 1) {
            [self addNewSpriteAtX:x andY:y withName:@"cat_rs"];
        }
        else {
            [self addNewSpriteAtX:x andY:y withName:@"ball_rs"];
        }
    }
    
    if(ctr >= 100) {
        [itemTimer invalidate];
        itemTimer = nil;
    }
}

-(void)addNewSpriteAtX:(float)x andY:(float)y withName:(NSString *)name {
    // create and add sprite
	CCSprite *sprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"%@.png", name]];
	[self addChild:sprite];
    
    // set anchor point
    sprite.anchorPoint = [[GCpShapeCache sharedShapeCache] anchorPointForShape:name];
    
    // create physics shape
    cpBody *body = [[GCpShapeCache sharedShapeCache] createBodyWithName:name inSpace:space withData:(__bridge void*)sprite];
    
    // set position
    body->p = ccp(x,y);
}


@end
