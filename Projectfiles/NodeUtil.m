//
//  NodeUtil.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 12/27/12.
//

#import "NodeUtil.h"
#import "cocos2d.h"

#pragma mark NodeUtilUserData

@interface NodeUtilUserData : NSObject
@property(strong) CCLayer *layer;
@property(strong) CCNode *node;
@property(strong) NSString *filename;
@end

@implementation NodeUtilUserData
@synthesize layer;
@synthesize node;
@synthesize filename;
@end

#pragma mark NodeUtil

@interface NodeUtil () {
}

-(void)removeNodeWithTimer:(NSTimer*)timer;
-(void)explodeNodeWithTimer:(NSTimer*)timer;

@end

@implementation NodeUtil

#pragma mark NodeUtil

-(void)explodeNode:(CCNode *)node ofLayer:(CCLayer *)layer withExplosionPlistFilename:(NSString *)filename {
    NodeUtilUserData *userData = [[NodeUtilUserData alloc] init];
    userData.filename = filename;
    userData.layer = layer;
    userData.node = node;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(explodeNodeWithTimer:) userInfo:userData repeats:NO];
}

-(void)shrinkAndExplodeNode:(CCNode *)node ofLayer:(CCLayer *)layer withExplosionPlistFilename:(NSString *)filename {
    NodeUtilUserData *userData = [[NodeUtilUserData alloc] init];
    userData.filename = filename;
    userData.layer = layer;
    userData.node = node;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(explodeNodeWithTimer:) userInfo:userData repeats:NO];

    CCFiniteTimeAction *shrinkAction = [CCScaleTo actionWithDuration:0.5 scale:0.01];
    [node runAction:shrinkAction];
}

#pragma mark private methods

-(void) removeNodeWithTimer:(NSTimer*)timer {
    
    NodeUtilUserData *userData = (NodeUtilUserData*) timer.userInfo;
    
    if(userData.node) {
        [userData.layer removeChild:userData.node cleanup:YES];
        [timer invalidate];
    }
}

-(void) explodeNodeWithTimer:(NSTimer*)timer {
    NodeUtilUserData *ud = (NodeUtilUserData*) timer.userInfo;
    
    CCParticleSystemQuad *explosion;
    explosion = [CCParticleSystemQuad particleWithFile:ud.filename];
    explosion.position = ud.node.position;
    [ud.layer removeChild:ud.node cleanup:YES];
    [ud.layer addChild:explosion];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(removeNodeWithTimer:) userInfo:ud repeats:NO];
}

@end
