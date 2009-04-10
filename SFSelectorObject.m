//
//  SFSelectorObject.m
//  SilverFlow
//
//  Created by Julius Eckert on 07.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SFSelectorObject.h"

@implementation SFSelectorObject

- (id)initWithLayer:(CALayer*)pLayer asSelector:(int)sel {
	if (self = [super init]) {
		selector = sel;
		curSelector = 1;
		parentLayer = pLayer;
		sfImage = nil;
		
		[self setupLayers];
		[self updatePosition];
	}
	return self;
}

-(void) redraw {
    [CATransaction flush];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
	
	[mainLayer setNeedsDisplay];
	
    [CATransaction commit];
}


- (void)setImage:(NSImage*)img {
	@try {
		if (sfImage) [sfImage release];
		if (img) {
			sfImage = [img retain];
		} else sfImage = nil;
		[self redraw];
	}
	@catch (NSException *exception) {
		NSLog(@"############ setImage: Caught %@: %@", [exception name], [exception reason]);
	}
}

- (void)updatePosition {
	// both selectors on the right
	if (curSelector == 1) {
		
		textLayer.opacity = 1;
		textLayer.anchorPoint = CGPointMake(1, 0.5);
		textLayer.alignmentMode = kCAAlignmentRight;
		mainLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
		
		if (selector == 2) {
			mainLayer.position = CGPointMake([parentLayer frame].size.width+90, 130);
			mainLayer.zPosition = -200;
			
			textLayer.position = CGPointMake([parentLayer frame].size.width+35, 150);
			textLayer.zPosition = -200;
		}
		
		if (selector == 3) {
			mainLayer.position = CGPointMake([parentLayer frame].size.width+90, 60);
			mainLayer.zPosition = -200;
			
			textLayer.position = CGPointMake([parentLayer frame].size.width+35, 80);
			textLayer.zPosition = -200;
		}
	}
	
	// one in the middle, one on the right
	if (curSelector == 2) {
		
		if (selector == 2) {
			mainLayer.position = CGPointMake([parentLayer frame].size.width/2, 60);
			mainLayer.zPosition = -50;
			mainLayer.transform = CATransform3DMakeScale(0.8, 0.8, 1);
			
			textLayer.opacity = 0;
		}
		
		if (selector == 3) {
			mainLayer.position = CGPointMake([parentLayer frame].size.width+90, 130);
			mainLayer.zPosition = -200;
			mainLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
			
			textLayer.opacity = 1;
			textLayer.anchorPoint = CGPointMake(1, 0.5);
			textLayer.alignmentMode = kCAAlignmentRight;
			textLayer.position = CGPointMake([parentLayer frame].size.width+35, 150);
			textLayer.zPosition = -200;
		}
	}
	
	// one on the left, one in the middle
	if (curSelector == 3) {
		
		if (selector == 2) {
			mainLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1);
			mainLayer.position = CGPointMake(0, 30);
			mainLayer.zPosition = -100;
			
			textLayer.opacity = 1;
			textLayer.anchorPoint = CGPointMake(0, 0.5);
			textLayer.alignmentMode = kCAAlignmentLeft;
			textLayer.position = CGPointMake(40, 50);
			textLayer.zPosition = -100;
		}
		
		if (selector == 3) {
			mainLayer.position = CGPointMake([parentLayer frame].size.width/2, 60);
			mainLayer.zPosition = -50;
			mainLayer.transform = CATransform3DMakeScale(0.8, 0.8, 1);
			
			textLayer.opacity = 0;
		}
	}
	
}
- (void)setText:(NSString*)text {
    [CATransaction flush];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
	
	textLayer.string = text;
	
    [CATransaction commit];
}


- (void)setCurrentSelector:(int)sel {
	curSelector = sel;
	[self updatePosition];
}

- (void)setupLayers {
	mainLayer = [CALayer layer];
	mainLayer.name = @"mainLayer";
	mainLayer.bounds = CGRectMake( 0, 0, 128, 128 );
	mainLayer.anchorPoint = CGPointMake(0.5,0);
	mainLayer.delegate = self;
	mainLayer.position = CGPointMake(0,0);
	mainLayer.borderWidth = 0;
		
	[parentLayer addSublayer:mainLayer];
	[mainLayer setNeedsDisplay];
	
	textLayer = [CATextLayer layer];
	textLayer.name = @"textLayer";
	textLayer.string = @"Öffnen";
	textLayer.font                  = [NSFont boldSystemFontOfSize:16];
	textLayer.fontSize              = 20;
	textLayer.bounds				= CGRectMake( 0, 0, 150, 40 );
	textLayer.alignmentMode         = kCAAlignmentLeft;
	textLayer.anchorPoint			= CGPointMake(0.5, 0.5);
	textLayer.position				= CGPointMake(0, -40);
	textLayer.foregroundColor		= CGColorCreateGenericRGB(255, 255, 255, 255);
	textLayer.zPosition = 0;
	textLayer.opacity = 1.0;
	[textLayer setTruncationMode:kCATruncationEnd];
	[parentLayer addSublayer:textLayer];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)cgContext;
{    
	[NSGraphicsContext saveGraphicsState];
	NSRect drawingRect = NSRectFromCGRect( CGContextGetClipBoundingBox( cgContext ) );
	NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:cgContext flipped:NO];
	[NSGraphicsContext setCurrentContext:context];
	
	NSBezierPath *cornerEraser = nil;
	cornerEraser = [NSBezierPath bezierPath];
	[cornerEraser appendBezierPathWithRect:drawingRect]; //RoundedRectangle:drawingRect withRadius:4];
	//[cornerEraser addClip];
	
	NSRect topRect, bottomRect;
	NSDivideRect(drawingRect, &topRect, &bottomRect, NSHeight(drawingRect) /2, NSMaxYEdge);
	[[NSColor colorWithCalibratedRed:0.07 green:0.07 blue:0.07 alpha:1.0] set];
	NSRectFill(drawingRect);
	
	[[NSColor colorWithCalibratedRed:0.35 green:0.36 blue:0.35 alpha:0.5] setStroke];
	[cornerEraser stroke];
	
	if (sfImage) {
		NSRect imgRect = drawingRect;
		imgRect.origin.x += 5;
		imgRect.origin.y += 5;
		imgRect.size.width -= 10;
		imgRect.size.height -= 10;
		[sfImage setFlipped:false];
		[sfImage drawInRect:imgRect fromRect:rectFromSize([sfImage size]) operation:NSCompositeSourceOver fraction:1.0];
	}
	[NSGraphicsContext restoreGraphicsState];        
}

@end
