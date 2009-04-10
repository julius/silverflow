//
//  SFCollectingSearchObjectView.m
//  SilverFlow
//
//  Created by Julius Eckert on 06.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SFCollectingSearchObjectView.h"
#import "CGSPrivate.h"

CGSConnection cgs;
int cgs_handle;
#define CGS_EFFECT_DURATION 0.16

bool zoomedIn = false;

@implementation SFCollectingSearchObjectView

- (void)setResultArray:(NSMutableArray *)newResultArray {
	[super setResultArray:newResultArray];
	
	[(SilverFlow*)[[self window] windowController] resultsUpdated:self];
}


- (id)getResultController {
	return resultController;
}

- (BOOL)becomeFirstResponder {
	[(SilverFlow*)[[self window] windowController] selectorIsFirstResponder:self];
	return [super becomeFirstResponder];
}


- (IBAction)showResultView:(id)sender {
	if ([[self window] firstResponder] != self) [[self window] makeFirstResponder:self];
	if (([[resultController window] isVisible]) && (sender != nil)) return;
	
	[[resultController window] setLevel:[[self window] level] +1];
	[[resultController window] setFrameUsingName:@"results" force:YES];
	
	NSRect windowRect = [[resultController window] frame];
	NSRect screenRect = [[[resultController window] screen] frame];
	
	windowRect.origin.y = [[self window] frame].origin.y - windowRect.size.height;
	if (zoomedIn) windowRect.origin.y = [[self window] frame].origin.y - windowRect.size.height*2;
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

/*
 ----------------------------
 Text Editor stuff
 ----------------------------
 */
-(void) someEffect:(bool)left {
	cgs_handle=-1;
	float duration = CGS_EFFECT_DURATION;
	CGSTransitionSpec spec;
	
	spec.unknown1=0;
	spec.type=CGSFlip;
	if (left)
		spec.option=CGSLeft | (1<<7);
	else
		spec.option=CGSRight | (1<<7);
	spec.backColour=0;
	spec.wid=[[self window] windowNumber];
	
	cgs= _CGSDefaultConnection();
	
	CGSNewTransition(cgs, &spec, &cgs_handle);
	[[self window] display];
	CGSInvokeTransition(cgs, cgs_handle, duration);
	
	usleep((useconds_t)(1000000*duration));
	
	//	Release our variables
	CGSReleaseTransition(cgs, cgs_handle);
	cgs_handle=0;
}

- (void)transmogrifyWithText:(NSString *)string {
	[super transmogrifyWithText:string];
	if ([self currentEditor]) {
		//[self setNeedsDisplay:true];
		NSRect fRect = [[[self window] contentView] frame];
		[self setFrame:NSMakeRect(fRect.origin.x+10, fRect.origin.y+10, fRect.size.width-20, fRect.size.height-40)];
		
		/*
		NSRect editorFrame = [self frame];
		editorFrame.origin = NSZeroPoint;
		editorFrame = NSInsetRect(editorFrame, 10, 10);
		[[[self currentEditor] enclosingScrollView] setFrame: editorFrame];
		[[self currentEditor] setMinSize:editorFrame.size];
		//[[self currentEditor] setTextColor:[NSColor whiteColor]];   // #B:BLACK
		[(NSTextView*)[self currentEditor] setContinuousSpellCheckingEnabled:NO];
		//[[self currentEditor] setFont:[NSFont fontWithName:@"Monaco" size:11]];
		//[(NSTextView*)[self currentEditor] setInsertionPointColor:[NSColor whiteColor]];
		/**/
		[[[self window] windowController] editorEnabled:self];
	}
	[self someEffect:![self isLeftSelector]];
}

- (void)textDidEndEditing:(NSNotification *)aNotification {
	[super textDidEndEditing:aNotification];
	[self setNeedsDisplay:true];
	[self someEffect:[self isLeftSelector]];
	[[[self window] windowController] editorDisabled];
}


- (bool) isLeftSelector {
	return (self == [self directSelector]);
}


- (void)drawRect:(NSRect)rect {
	[[NSColor blackColor] set];
	NSRectFill(rect);

	NSRect bottomRect = rect;
	//bottomRect = NSInsetRect(bottomRect, 25, 25);
	[[NSColor colorWithCalibratedRed:0.25 green:0.25 blue:0.25 alpha:1.0] setFill];
	NSBezierPath* clipper = [NSBezierPath bezierPath];
	[clipper appendBezierPathWithRoundedRectangle:bottomRect withRadius:8];
	[clipper addClip];
	NSRectFill(bottomRect);
	
	bottomRect = NSInsetRect(bottomRect, 1, 1);
	[[NSColor colorWithCalibratedRed:0.85 green:0.85 blue:0.85 alpha:1] setFill];
	clipper = [NSBezierPath bezierPath];
	[clipper appendBezierPathWithRoundedRectangle:bottomRect withRadius:8];
	[clipper addClip];
	NSRectFill(bottomRect);
}

#define EFT_ZOOM_IN_DURATION 0.15
#define EFT_ZOOM_OUT_DURATION 0.1

- (bool)zoomed {
	return zoomedIn;
}

- (BOOL)performKeyEquivalent:(NSEvent*)evt {
	if ([evt modifierFlags] & NSShiftKeyMask) {
		if (([[evt charactersIgnoringModifiers] characterAtIndex:0] == 0xF700) && (!zoomedIn)){
			zoomedIn = true;
			[self showResultView:nil];
			// ------ zoom in -------------
			NSDate* d = [NSDate date];
			CGSGetWindowTransform(_CGSDefaultConnection(), [[self window] windowNumber], &oldT);
			
			while (true) {
				float fraction = (- [d timeIntervalSinceNow]) / EFT_ZOOM_IN_DURATION;
				if (fraction > 1) break;
				
				float s = 1 - 0.5*fraction;
				float t = fraction * 0.5;
				
				CGAffineTransform curT = oldT; 
				curT = CGAffineTransformTranslate(curT, [[self window] frame].size.width*t*1.5, [[self window] frame].size.height*t);
				curT = CGAffineTransformScale(curT, s, s);
				CGSSetWindowTransform(_CGSDefaultConnection(), [[self window] windowNumber], curT);
			}
			
			return false;
		}
		
		if (([[evt charactersIgnoringModifiers] characterAtIndex:0] == 0xF701) && (zoomedIn)){
			zoomedIn = false;
			[self showResultView:nil];
			// ------ zoom out ------------
			NSDate* d = [NSDate date];
			
			while (true) {
				float fraction = (- [d timeIntervalSinceNow]) / EFT_ZOOM_OUT_DURATION;
				if (fraction > 1) break;
				
				float s = 0.5 + 0.5*fraction;
				float t = 0.5 - fraction * 0.5;
				
				CGAffineTransform curT = oldT;
				curT = CGAffineTransformTranslate(curT, [[self window] frame].size.width*t*1.5, [[self window] frame].size.height*t);
				curT = CGAffineTransformScale(curT, s, s);
				CGSSetWindowTransform(_CGSDefaultConnection(), [[self window] windowNumber], curT);
			}
			
			CGSSetWindowTransform(_CGSDefaultConnection(), [[self window] windowNumber], oldT);
			return false;
		}
	}
	return [super performKeyEquivalent:evt];
}

/*
- (void)keyDown:(NSEvent *)evt {
	if ([evt modifierFlags] & NSShiftKeyMask) {
		NSLog(@"cmd ignored");
		return;
	}	

	[super keyDown:evt];
}
/**/


@end
