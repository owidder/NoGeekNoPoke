//
//  PointsLayer.h
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 10/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PointsLayer : CCLayer {
    
    /**
     Labels for the current distance points
     */
    CCLabelTTF *redGalaxyPointsLabel;
    CCLabelTTF *blueGalaxyPointsLabel;
    CCLabelTTF *greenGalaxyPointsLabel;
    CCLabelTTF *rgbGalaxyPointsLabel;
}

-(void) showRedGalaxyPoints:(int)points atPosition:(CGPoint)pos;
-(void) showBlueGalaxyPoints:(int)points atPosition:(CGPoint)pos;
-(void) showGreenGalaxyPoints:(int)points atPosition:(CGPoint)pos;
-(void) showRgbGalaxyPoints:(int)points atPosition:(CGPoint)pos;

-(void) removeCurrentGalaxyLabel;

@end
