//
//  SFCoverFlowView.h
//  SilverFlow
//
//  Created by Julius Eckert on 05.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "SFCoverFlow.h"
#import "SFSelectorObject.h"

@interface SFCoverFlowView : NSView {
	SFCoverFlow* coverFlow;
	
	CALayer* dof;
	CATextLayer* textLayer;
	CATextLayer* textLayer2;
	CATextLayer* textLayer3;
	
	SFSelectorObject* soAction;
	SFSelectorObject* soIndirect;
}

@property (readonly, assign) SFSelectorObject* soAction;
@property (readonly, assign) SFSelectorObject* soIndirect;

- (void)setupLayers;
- (void)setText:(NSString*)text details:(NSString*)details;
- (SFCoverFlow*) coverflow;
- (void)setSelector:(int)sel;
- (void)dofRedraw;

@end
