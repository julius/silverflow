//
//  SFCoverFlow.h
//  SilverFlow
//
//  Created by Julius Eckert on 02.02.08.
//  Copyright 2008 Julius Eckert. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "SFCFObjectManager.h"

@class SilverFlow;

@interface SFCoverFlow : NSObject {
	CALayer* parentLayer;
	SilverFlow* sflow;

	SFCFObjectManager* objMan;
	
	NSRange fullRange;
	NSRange currentRange;
	NSRange selectionRange;

	int selection;
	int selectionRangeStart;
	int selectionRangeEnd;
	
	id delegate;
	
	bool updaterValid;
	NSThread* updaterThread;
	
	int selector;
	
	bool rangeIsNew;
}

-(SFCoverFlow*)initWithLayer:(CALayer*)layer;
-(void) setItemCount:(int)size;
-(void) setSelection:(int)sel;
-(NSRange) selectionRange;
- (void)setSilverFlow:(SilverFlow*)sf;
- (void)setImage:(NSImage*)img atIndex:(int)i;

-(void) setDelegate:(id)aDelegate;

-(void) setSelector:(int)sel;

@end

@interface NSObject (SFCF)
- (void) requireImageAtIndex:(int)i;
@end;
