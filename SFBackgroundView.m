//
//  SFBackgroundView.m
//  SilverFlow
//
//  Created by Julius Eckert on 19.01.08.
//  Copyright 2008 Julius Eckert. All rights reserved.
//

#import "SFBackgroundView.h"

@implementation SFBackgroundView

- (void)drawRect:(NSRect)rect {
	NSRect fullRect = [self convertRect:[self frame] fromView:[self superview]];
	NSBezierPath *cornerEraser;
	if (![[self window] isOpaque] && [[self window] contentView] == self && [[self window] backgroundColor] == [NSColor clearColor]) {
		cornerEraser = [NSBezierPath bezierPath];
		[cornerEraser appendBezierPathWithRoundedRectangle:[self frame] withRadius:4];
		[cornerEraser addClip];
	}
	
	[[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0] set];
	NSRectFill(fullRect);

	[[NSColor colorWithCalibratedRed:0.7 green:0.7 blue:0.7 alpha:0.8] setStroke];
	if (cornerEraser != nil) {
		[cornerEraser stroke];
	}

	NSRect topRect, bottomRect;
	NSDivideRect(fullRect, &topRect, &bottomRect, 10, NSMaxYEdge);

	NSColor* color1 = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0];
	NSColor* color2 = [NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:0.0];
	
	NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:color1 endingColor:color2];
	
	[gradient drawInRect:topRect angle:90];

	[[NSColor colorWithCalibratedRed:0.15 green:0.15 blue:0.15 alpha:1.0] set];
	NSRectFill(bottomRect);
	
	NSDivideRect(fullRect, &topRect, &bottomRect, 25, NSMaxYEdge);
	[[NSColor blackColor] setFill];
	NSRectFill(bottomRect);
	
}

@end
