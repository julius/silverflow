//
//  SilverFlow.m
//  SilverFlow
//
//  Created by Julius Eckert on 05.05.08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//
//  QS Interface template by Vacuous Virtuoso
//

#import <QSEffects/QSWindow.h>
#import <QSInterface/QSSearchObjectView.h>
#import <QSInterface/QSObjectCell.h>

#import "SilverFlow.h"

@implementation SilverFlow

- (id)init {
	id result = [self initWithWindowNibName:@"SilverFlow"];
	[SFResources sharedInstance];
	return result;
}

- (void) windowDidLoad {

	[super windowDidLoad];

	QSWindow *window=(QSWindow *)[self window];

    [[self window] setLevel:NSModalPanelWindowLevel];
    [[self window] setFrameAutosaveName:@"SilverFlowWindow"];

	// If it's off the screen, bring it back in
    [[self window]setFrame:constrainRectToRect([[self window]frame],[[[self window]screen]visibleFrame]) display:NO];


	[window setHideOffset:NSMakePoint(0,0)];
	[window setShowOffset:NSMakePoint(0,0)];

	[window setShowEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSBingeEffect",@"transformFn",@"show",@"type",[NSNumber numberWithFloat:0.1],@"duration",nil]];
	[window setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSShrinkEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:.15],@"duration",nil]];
	
	// setWindowProperty returns an error, unfortunately... ignore it
	[window setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSExplodeEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:0.1],@"duration",nil] forKey:kQSWindowExecEffect];
	
    NSArray *theControls=[NSArray arrayWithObjects:dSelector,aSelector,iSelector,nil];
    foreach(theControl,theControls){
		[theControl setPreferredEdge:NSMinYEdge];
		[theControl setResultsPadding:NSMinY([dSelector frame])];
		NSCell *theCell=[theControl cell];
		[(QSObjectCell *)theCell setShowDetails:NO];
	}
	
	[[cfview coverflow] setSilverFlow:self];
	iconIndices = [[NSMutableArray alloc] init];
	NSThread* t = [[NSThread alloc] initWithTarget:self selector:@selector(iconLoader) object:nil];
	[t start];
}

- (void)selectorIsFirstResponder:(id)sender {
	if (sender == dSelector) {
		[cfview setSelector:1];
	} 
	if (sender == aSelector) {
		[cfview setSelector:2];
	} 
	if (sender == iSelector) {
		[cfview setSelector:3];
	} 
	[self sfUpdate];
}


// find current index in resultArray
- (int)positionInRange {
	int i;
	for (i=0; i<[[dSelector resultArray] count]; i++) {
		QSObject* cur = [[dSelector resultArray] objectAtIndex:i];
		if (cur == [dSelector objectValue]) return i;
	}
	return 0;//-1;
}

- (NSImage*)getImageOfSelector:(QSSearchObjectView*)sel {
	QSObject* qsobj = [sel objectValue];
	if (qsobj) {
		@try {
			NSImage* img = [[NSImage alloc] initWithSize:NSMakeSize(128,128)];
			[img lockFocus];
			[[sel cell] drawObjectImage:qsobj inRect:NSMakeRect(0,0,128,128) cellFrame:NSMakeRect(0,0,128,128) controlView:sel flipped:false opacity:1.0];
			[img unlockFocus];
			return img;
		}
		@catch (NSException *exception) {
			NSLog(@"############ getImageOfSelector: Caught %@: %@", [exception name], [exception reason]);
		}
		return nil;
	} else return nil;
}

- (void)sfUpdate {
	bool rd = false;
	
	// ---------- text --------------
	if ([dSelector objectValue]) {
		QSObject* qsobj = nil;
		if ([[self window] firstResponder] == dSelector) qsobj = [dSelector objectValue];
		if ([[self window] firstResponder] == aSelector) qsobj = [aSelector objectValue];
		if ([[self window] firstResponder] == iSelector) qsobj = [iSelector objectValue];
		if (qsobj) {
			NSString* text = [NSString stringWithFormat:@"%@", [qsobj displayName]];
			NSString* details = [NSString stringWithFormat:@"%@", [qsobj details]];
			if ([qsobj details] == nil) details = @"";
			[cfview setText:text details:details];
		} else { [cfview setText:@"" details:@""]; }
	}
	
	if ([aSelector objectValue]) [[cfview soAction] setText:[[aSelector objectValue] displayName]];
	else [[cfview soAction] setText:@" - "];
	
	if ([iSelector objectValue]) [[cfview soIndirect] setText:[[iSelector objectValue] displayName]];
	else [[cfview soIndirect] setText:@" - "];
	
	// -------- coverflow ------------
	@synchronized(iconIndices) {
		[iconIndices removeAllObjects];
		[[cfview coverflow] setSelection:[self positionInRange]];
		//[[dSelector getResultController] resultIconLoader] loadIconsInRange:
	
	
		// ---------- selectorObjects ------------
		@try {
			if ([aSelector objectValue] != actionLast) {
				actionLast = [aSelector objectValue];
				if (actionLast) [[cfview soAction] setImage:[self getImageOfSelector:aSelector]];
				else [[cfview soAction] setImage:nil];
				rd = true;
			}
			if ([iSelector objectValue] != indirectLast) {
				indirectLast = [iSelector objectValue];
				if (indirectLast) [[cfview soIndirect] setImage:[self getImageOfSelector:iSelector]];
				else [[cfview soIndirect] setImage:nil];
				rd = true;
			}
		}
		@catch (NSException *exception) {
			NSLog(@"############ sfUpdate: Caught %@: %@", [exception name], [exception reason]);
		}/**/
		
	}
	
	if (rd) [cfview dofRedraw];
}


- (void)resultsUpdated:(id)sender {
	if (sender == dSelector) {
		[[cfview coverflow] setItemCount:[[dSelector resultArray] count]];
	}
	[self sfUpdate];
}

- (QSObject*)objectAtIndex:(int)i {
	if (![dSelector resultArray]) return nil;
	if ((i >= [[dSelector resultArray] count]) || (i<0)) return nil;
	return [[dSelector resultArray] objectAtIndex:i];
}

/* ---------------------------------------------------------------
      Image Loading
 ----------------------------------------------------------------- */
 

- (void)requireImageAtIndex:(int)i {
	QSObject* qsobj = [self objectAtIndex:i];
	if ([qsobj iconLoaded] == false) [qsobj loadIcon];
	[iconIndices addObject:[NSNumber numberWithInt:i]];
}

- (void)loadImageFor:(int)i {
	QSObject* qsobj = [self objectAtIndex:i];
	
	NSImage* img = nil;
	if (([[qsobj displayName] length] > 13) && ([[[qsobj displayName] substringWithRange:NSMakeRange(0,13)] isEqualToString:@"http://images"])) {
		/*
		@try {
			img = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[qsobj displayName]]];
		}
		@catch (NSException *exception) {
			NSLog(@"############ loadImageFor: Caught %@: %@", [exception name], [exception reason]);
		}/**/
		
	}
	if (img == nil) {
		
		img = [[NSImage alloc] initWithSize:NSMakeSize(128,128)];
		[img lockFocus];
		
		[[dSelector cell] drawObjectImage:qsobj inRect:NSMakeRect(0,0,128,128) cellFrame:NSMakeRect(0,0,128,128) controlView:dSelector flipped:false opacity:1.0];
		
		[img unlockFocus];
	}
	[[cfview coverflow] setImage:img atIndex:i];
	[cfview dofRedraw];
	//[[cfview coverflow] setImage:[QSResourceManager imageNamed:@"defaultAction"] atIndex:i];
}

- (void)iconLoader {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	int dr = 0;
	
	while (true) {
		@synchronized(iconIndices) {
			if ([iconIndices count] > 0) {
				int i = [[iconIndices objectAtIndex:0] intValue];
				[iconIndices removeObjectAtIndex:0];
				[self loadImageFor:i];
			} 
			
		}
		[NSThread sleepForTimeInterval:0.05];
	}
	
	[pool release];
}



- (NSSize)maxIconSize{
    return NSMakeSize(128,128);
}

- (void)showMainWindow:(id)sender{
	if ([[self window]isVisible])[[self window]pulse:self];
	[super showMainWindow:sender];
}

- (void)hideMainWindow:(id)sender{
	[[self window] saveFrameUsingName:@"SilverFlowWindow"];
	[super hideMainWindow:sender];
}

/*
*  If you want an effect such as an animation
*  when the indirect selector shows up,
*  the next three methods are for you to subclass.
*/

- (void)showIndirectSelector:(id)sender{
    [super showIndirectSelector:sender];
}

- (void)expandWindow:(id)sender{ 
    [super expandWindow:sender];
}

- (void)contractWindow:(id)sender{
    [super contractWindow:sender];
}

// When something changes, update the command string
- (void)firstResponderChanged:(NSResponder *)aResponder{
	[super firstResponderChanged:aResponder];
	[self updateDetailsString];
}
- (void)searchObjectChanged:(NSNotification*)notif{
	[super searchObjectChanged:notif];
	@try {
		[self updateDetailsString];
	}
	@catch (NSException *exception) {
		NSLog(@"############ searchObjectChanged: Caught %@: %@", [exception name], [exception reason]);
	}
}

// The method to update the command string
// Get rid of it if you're not having a commandView outlet
-(void)updateDetailsString{
	//[self sfUpdate];
	NSString *command=[[self currentCommand]description];
	[commandView setStringValue:command?command:@""];
	[self sfUpdate];
}

// Uncomment if you're having a customize button + pref pane
/*- (IBAction)customize:(id)sender{
	[[NSClassFromString(@"QSPreferencesController") sharedInstance]showPaneWithIdentifier:@"QSFumoInterfacePrefPane"];
}*/


- (void)actionActivate:(id)sender{
	[super actionActivate:sender];
}
- (void)updateViewLocations{
    [super updateViewLocations];
}


-(void) editorEnabled:(id)sender {
	[commandView setHidden:true];
	[cfview setHidden:true];
}

-(void) editorDisabled {
	[commandView setHidden:false];
	[cfview setHidden:false];
}


@end
