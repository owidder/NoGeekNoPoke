//
//  SetStringAction.h
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/11/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SetStringAction : CCFiniteTimeAction <NSCopying> {
}

@property (nonatomic, strong) NSString *nextString;

+(id) actionWithString:(NSString*)pString;

@end
