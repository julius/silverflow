//
//  SFSearchObjectView.m
//  SilverFlow
//
//  Created by Julius Eckert on 06.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SFSearchObjectView.h"


@implementation SFSearchObjectView



- (BOOL)becomeFirstResponder {
	[(SilverFlow*)[[self window] windowController] selectorIsFirstResponder:self];
	return [super becomeFirstResponder];
}


- (IBAction)showResultView:sender {
	if ([[self window] firstResponder] != self) [[self window] makeFirstResponder:self];
	if ([[resultController window] isVisible]) return;
	
	[[resultController window] setLevel:[[self window] level] +1];
	[[resultController window] setFrameUsingName:@"results" force:YES];
	
	NSRect windowRect = [[resultController window] frame];
	NSRect screenRect = [[[resultController window] screen] frame];
	
	windowRect.origin.y = [[self window] frame].origin.y - windowRect.size.height;
	if ([[self directSelector] zoomed]) windowRect.origin.y = [[self window] frame].origin.y - windowRect.size.height*2;
	windowRect.origin.x = [[self window] frame].origin.x + ([[self window] frame].size.width/2 - windowRect.size.width/2);
	
	windowRect = NSIntersectionRect(windowRect, screenRect);
	[[resultController window] setFrame:windowRect display:NO];
	
	[self updateResultView:sender];
	
	if ([[self controller] respondsToSelector:@selector(searchView:resultsVisible:)])
		[(id)[self controller] searchView:self resultsVisible:YES];
	
	if ([[self window] isVisible]) {
		
		[[resultController window] orderFront:nil];
		[[self window] addChildWindow:[resultController window] ordered:NSWindowAbove];
	}
}	


@end
