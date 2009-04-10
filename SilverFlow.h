//
//  SilverFlow.h
//  SilverFlow
//
//  Created by Julius Eckert on 05.05.08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//
//  QS Interface template by Vacuous Virtuoso
//

#import <Cocoa/Cocoa.h>
#import <QSInterface/QSResizingInterfaceController.h>

#import "SFResources.h"
#import "SFCoverFlowView.h"

@interface SilverFlow : QSResizingInterfaceController
{
	IBOutlet SFCoverFlowView* cfview;
	NSMutableArray* iconIndices;
	
	QSObject* actionLast;
	QSObject* indirectLast;
}

- (void)updateDetailsString;
- (void)resultsUpdated:(id)sender;
- (void)selectorIsFirstResponder:(id)sender;
- (void)sfUpdate;

@end

@interface NSObject (qswindow)
-(void) setWindowProperty:(NSDictionary*)dict forKey:(NSString*)key;
@end