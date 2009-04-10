//
//  SFCoverFlow.m
//  SilverFlow
//
//  Created by Julius Eckert on 02.02.08.
//  Copyright 2008 Julius Eckert. All rights reserved.
//

#import "SFCoverFlow.h"


@implementation SFCoverFlow
#define SFCF_SEL_RANGE_LENGTH 25

-(SFCoverFlow*)initWithLayer:(CALayer*)layer {
	if (self = [super init]) {
		parentLayer = layer;
		
		objMan = [[SFCFObjectManager alloc] initWithLayer:parentLayer];
		
		fullRange = NSMakeRange(0, 0);
		selectionRange = NSMakeRange(0, 0);
		currentRange = NSMakeRange(0, 0);
		
		updaterValid = true;
	}
	return self;
}

-(NSRange) selectionRange {
	return selectionRange;
}

- (void)setSilverFlow:(SilverFlow*)sf {
	sflow = sf;
}

- (void)updateObjects {
	int i;
	for (i=0; i<[objMan count]; i++) {
		SFCFObject* obj = [objMan objectAtIndex:i];
		if (![obj hasImage]) [sflow requireImageAtIndex:(i + selectionRangeStart)];
	}	
}

- (void)setImage:(NSImage*)img atIndex:(int)i {
	int ind = (i - selectionRangeStart);
	if ((ind < 0) || (ind >= [objMan count])) return;
	SFCFObject* obj = [objMan objectAtIndex:ind];
	[obj setImage:img];
}

-(void) updatePositions {
	float left = [parentLayer frame].size.width/2;
	int i;
	//for (i=0; i<[objMan count] && updaterValid; i++) {
	for (i=0; i<[objMan count]; i++) {
		SFCFObject* obj = [objMan objectAtIndex:i];
		
		//int sel_dist = (currentRange.location + i) - selection;
		int sel_dist = (selectionRange.location + i) - selection;
		
		
		if ((selector == 1) && (sel_dist != 0)) {
			// ----------- normales coverflow ------------------
			float z = -0.1*abs(sel_dist)-280;
			SFCFVector3f pos = SFCFMakeVector3f(left + sel_dist*60 + ((sel_dist<0)? -100 :  +100), 50, z);
			[obj setPosition:pos fast:false];
			
		} else if ((selector == 1) && (sel_dist == 0)) {
			float z = -40;
			
			SFCFVector3f pos = SFCFMakeVector3f(left, 50, z);
			[obj setPosition:pos fast:false];
			
		} else {
			
			// ---------- anderer selektor ----------------------  
			
			if (sel_dist != 0) {
				float z = -0.1*abs(sel_dist)-220;
				SFCFVector3f pos = SFCFMakeVector3f(left + ((sel_dist<0)? -800 : +800), 50, z);
				[obj setPosition:pos fast:rangeIsNew];
			} else {
				if (selector == 2) {
					float z = -80;
					SFCFVector3f pos = SFCFMakeVector3f(-40, 50, z);
					[obj setPosition:pos fast:false];
				}
				if (selector == 3) {
					float z = -300;
					SFCFVector3f pos = SFCFMakeVector3f(-160, 120, z);
					[obj setPosition:pos fast:false];
				}
			}
		}
		[obj setDist:sel_dist fast:rangeIsNew];
	}
	rangeIsNew = false;
}

- (void)initRange:(int)size {
	while ([objMan count] > 0) [objMan popEnd];

	int i;
	for (i=0; i<size; i++) [objMan pushNormalEnd];

	rangeIsNew = true;
	selection = 0;
	selectionRangeStart = 0;
	selectionRangeEnd = size-1;
	selectionRange = NSMakeRange(selectionRangeStart, selectionRangeEnd - selectionRangeStart);
}

- (void)selectionInc {
	selection ++;
	
	int selectionRangeStart2 = (selection-SFCF_SEL_RANGE_LENGTH/2 < 0) ? 0 : selection-SFCF_SEL_RANGE_LENGTH/2;
	if (selectionRangeStart < selectionRangeStart2) [objMan popStart];
	selectionRangeStart = selectionRangeStart2;
	
	selectionRangeEnd ++;
	if (selectionRangeEnd >= fullRange.location + fullRange.length) selectionRangeEnd--;
	else [objMan pushNormalEnd];
	
	selectionRange = NSMakeRange(selectionRangeStart, selectionRangeEnd - selectionRangeStart);
}

- (void)selectionDec {
	selection --;
	
	int selectionRangeStart2 = (selection-SFCF_SEL_RANGE_LENGTH/2 < 0) ? 0 : selection-SFCF_SEL_RANGE_LENGTH/2;
	if (selectionRangeStart > selectionRangeStart2) [objMan pushNormalStart];
	selectionRangeStart = selectionRangeStart2;

	if (selection + SFCF_SEL_RANGE_LENGTH/2 < fullRange.location + fullRange.length) {
		[objMan popEnd];
		selectionRangeEnd --;
	}
	
	selectionRange = NSMakeRange(selectionRangeStart, selectionRangeEnd - selectionRangeStart);
}

-(void) setItemCount:(int)size {
	fullRange.location = 0;
	fullRange.length = size;
	
	int len = SFCF_SEL_RANGE_LENGTH/2;
	if (len > size) len = size;
	[self initRange:len];
}

-(void) setSelection:(int)sel {
	if (sel != selection) {
		int i;
		int diff = abs(sel-selection);
		if (sel > selection) {
			for (i=0; i<diff ; i++) [self selectionInc];
		} else {
			for (i=0; i<diff ; i++) [self selectionDec];
		}
	}
	
	[self updatePositions];
	[self updateObjects];
/*
	updaterValid = true;
	//if (!updaterThread) [NSThread detachNewThreadSelector:@selector(updater) toTarget:[self retain] withObject:nil];
 /**/
}

-(void) setDelegate:(id)aDelegate {
	[delegate release];
	delegate = [aDelegate retain];
}

-(void) setSelector:(int)sel {
	selector = sel;
	[self updatePositions];
}

@end
