//
//  SFSelectorObject.h
//  SilverFlow
//
//  Created by Julius Eckert on 07.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface SFSelectorObject : NSObject {
	CALayer* parentLayer;
	CALayer* mainLayer;
	CATextLayer* textLayer;
	NSImage* sfImage;
	int selector;
	int curSelector;
}

- (id)initWithLayer:(CALayer*)pLayer asSelector:(int)sel;
- (void)setupLayers;
- (void)updatePosition;
- (void)setCurrentSelector:(int)sel;
- (void)setText:(NSString*)text;
- (void)setImage:(NSImage*)img;

@end
