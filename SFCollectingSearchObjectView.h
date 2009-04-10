//
//  SFCollectingSearchObjectView.h
//  SilverFlow
//
//  Created by Julius Eckert on 06.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QSCollectingSearchObjectView.h"

@class SilverFlow;

@interface SFCollectingSearchObjectView : QSCollectingSearchObjectView {
	CGAffineTransform oldT;
}

@end

@interface NSObject (silverflow)

- (void)resultsUpdated:(id)sender;
- (void)sfUpdate;
- (id)getResultController;
- (void)selectorIsFirstResponder:(id)sender;
- (bool) isLeftSelector;

@end