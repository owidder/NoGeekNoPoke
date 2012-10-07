//
//  RemoveFromParentAction.m
//  NoGeekNoPoke
//
//

#import "RemoveFromParentAction.h"


@implementation RemoveFromParentAction

#pragma mark RemoveFromParentAction

+(id)action {
	return [[self alloc] init];
}

#pragma mark CCAction

-(void) startWithTarget:(id)aTarget
{
	[super startWithTarget:aTarget];
	[[aTarget parent] removeChild:aTarget cleanup:YES];
}

@end