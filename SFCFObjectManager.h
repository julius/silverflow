//
//  SFCFObjectManager.h
//  SilverFlow
//
//  Created by Julius Eckert on 03.02.08.
//  Copyright 2008 Julius Eckert. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "SFResources.h"
#import "SFCFObject.h"

@interface SFCFObjectManager : NSObject {
	CALayer* parentLayer;
	
	NSMutableArray* objectsNormal;
	NSMutableArray* objectsCache;
	NSMutableArray* objectsCurrent;	
}

-(SFCFObjectManager*)initWithLayer:(CALayer*)layer;
-(SFCFObject*) pushNormalEnd;
-(SFCFObject*) pushNormalStart;
-(void) popStart;
-(void) popEnd;
-(SFCFObject*) objectAtIndex:(int)index;
-(int) indexOf:(SFCFObject*)obj;
-(int) count;
-(void) cleanNormal:(SFCFObject*)obj;

@end
