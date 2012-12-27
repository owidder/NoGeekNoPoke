//
//  NodeUtil.h
//  NoGeekNoPoke
//
//  Created by Oliver Widder on 12/27/12.
//
//  Some useful methods regarding nodes
//

#import <Foundation/Foundation.h>

@interface NodeUtil : NSObject


-(void)explodeNode:(CCNode*)node ofLayer:(CCLayer*)layer withExplosionPlistFilename:(NSString*)filename;

@end


