//
//  NodeUtil.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 12/27/12.
//

#import "NodeUtil.h"

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

-(void) removeNode:(NSTimer*)timer;

-(void) explodeNode:(NSTimer*)timer;

@end

@implementation NodeUtil

#pragma mark NodeUtil

-(void)explodeNode:(CCNode *)node ofLayer:(CCLayer *)layer withExplosionPlistFilename:(NSString *)filename {
    NodeUtilUserData *userData = [[NodeUtilUserData alloc] init];
    userData.filename = filename;
    userData.layer = layer;
    userData.node = node;
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(explodeNode:) userInfo:userData repeats:NO];
}


#pragma mark private methods

-(void) removeNode:(NSTimer*)timer {
    
    NodeUtilUserData *userData = (NodeUtilUserData*) timer.userInfo;
    
    if(userData.node) {
        [userData.layer removeChild:userData.node cleanup:YES];
        [timer invalidate];
    }
}

-(void) explodeNode:(NSTimer*)timer {
    NodeUtilUserData *userData = (NodeUtilUserData*) timer.userInfo;
    
    CCParticleSystemQuad *explosion;
    explosion = [CCParticleSystemQuad particleWithFile:userData.filename];
    explosion.position = userData.node.position;
    [userData.layer removeChild:userData.node cleanup:YES];
    [userData.layer addChild:explosion];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(removeNode:) userInfo:userData repeats:NO];
}

@end
