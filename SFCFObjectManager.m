//
//  SFCFObjectManager.m
//  SilverFlow
//
//  Created by Julius Eckert on 03.02.08.
//  Copyright 2008 Julius Eckert. All rights reserved.
//

#import "SFCFObjectManager.h"


@implementation SFCFObjectManager

#define SFCF_NORMAL_COUNT 30

-(SFCFObjectManager*)initWithLayer:(CALayer*)layer {
	if (self = [super init]) {
		parentLayer = layer;
		
		int i;
		
		objectsNormal = [[NSMutableArray alloc] init];
		for (i=0; i<SFCF_NORMAL_COUNT; i++) {
			SFCFObject* sfo = [[SFCFObject alloc] initWithLayer:parentLayer withImage:[[SFResources sharedInstance] getStandart]];
			[objectsNormal addObject:sfo];
			[self cleanNormal:sfo];
		}
		
		objectsCurrent = [[NSMutableArray alloc] init];
	}
	return self;
}

-(SFCFObject*) unusedNormal {
	int i;
	for (i=0; i<[objectsNormal count]; i++)
		if ([objectsCurrent containsObject:[objectsNormal objectAtIndex:i]] == false)
			return [objectsNormal objectAtIndex:i];
	return nil;
}

-(SFCFObject*) pushNormalEnd {
	id obj = [self unusedNormal];
	if (obj) [objectsCurrent addObject:obj];
	return obj;
}

-(SFCFObject*) pushNormalStart {
	id obj = [self unusedNormal];
	if (obj) [objectsCurrent insertObject:obj atIndex:0];
	return obj;
}

-(void) cleanNormal:(SFCFObject*)obj {
	[obj setImage:nil];  // SPEED HACK - SHOULD LOOK CRAPPY => WRONG ICONS !! <- fixed by cleanOne

	SFCFVector3f pos = [obj position];
	pos.y += 6000;
	[obj setPosition:pos fast:YES];
	[obj setDist:1 fast:true];
}

-(void) popStart {
	if ([objectsCurrent count] == 0) return;
	SFCFObject* obj = [objectsCurrent objectAtIndex:0];
	[self cleanNormal:obj];
	[objectsCurrent removeObjectAtIndex:0];
}

-(void) popEnd {
	if ([objectsCurrent count] == 0) return;
	SFCFObject* obj = [objectsCurrent lastObject];
	[self cleanNormal:obj];
	[objectsCurrent removeLastObject];
}

-(SFCFObject*) objectAtIndex:(int)index {
	return [objectsCurrent objectAtIndex:index];
}

-(int) indexOf:(SFCFObject*)obj {
	return [objectsCurrent indexOfObject:obj];
}

-(int) count {
	return [objectsCurrent count];
}

@end
