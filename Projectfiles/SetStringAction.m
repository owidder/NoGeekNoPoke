//
//  SetStringAction.m
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SetStringAction.h"


@implementation SetStringAction

@synthesize nextString = _nextString;

#pragma mark SetStringAction

+(id) actionWithString:(NSString *)pString
{
    SetStringAction *setStringAction = [[self alloc] init];
    setStringAction.nextString = pString;
    
    return setStringAction;
}

#pragma mark CCAction

-(void) startWithTarget:(id)aTarget
{
    if([aTarget isKindOfClass:[CCLabelTTF class]]) {
        CCLabelTTF *node = (CCLabelTTF*) aTarget;
        [node setString:_nextString];
    }
}

@end
