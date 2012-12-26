//
//  PileGameLayer.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 12/26/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PileGameLayer.h"
#import "GCpShapeCache.h"

#define kAccelerationFilterFactor 0.05f

#undef WITH_ACCELERATION

#pragma mark enums

enum {
	kTagBatchNode = 1,
};

#pragma mark C Callbacks

static void eachBody(cpBody *body, void *data)
{
	CCSprite *sprite = (__bridge CCSprite*) body->data;
	if( sprite )
    {
		[sprite setPosition: body->p];
		[sprite setRotation: (float) CC_RADIANS_TO_DEGREES( -body->a )];
	}
}

#pragma mark extension

@interface PileGameLayer ()
{
    NSTimer *itemTimer;
    cpSpace *space;
}

-(void)step:(ccTime)dt;
-(void)addNewSprite:(float)x y:(float)y;
-(void)nextItem;

@end

#pragma mark implementation

@implementation PileGameLayer

#pragma mark data

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
}

-(id)init
{
	if( (self=[super init])) {
		
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
        
		[self addNewSprite:200 y:200];
		
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
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		
        [self addNewSprite: location.x y:location.y];
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

-(void) step:(ccTime)delta
{
	int steps = 2;
	CGFloat dt = delta/(CGFloat)steps;
	
	for(int i=0; i<steps; i++)
    {
		cpSpaceStep(space, dt);
	}
    cpSpaceEachBody(space, &eachBody, nil);
}

-(void)nextItem {
    static int ctr = 0;
    
    CGSize wins = [[CCDirector sharedDirector] winSize];
    
    int x = rand()%(int)(wins.width);
    int y = rand()%300 + 500;
    [self addNewSprite:x y:y];
    
    if(ctr++ >= 150) {
        [itemTimer invalidate];
        itemTimer = nil;
    }
}

-(void)addNewSprite: (float)x y:(float)y
{
    //    NSString *name = names[rand()%7];
    NSString *name = itemNames[rand()%8];
    
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
