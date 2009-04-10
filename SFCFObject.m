//
//  SFCFObject.m
//  SilverFlow
//
//  Created by Julius Eckert on 02.02.08.
//  Copyright 2008 Julius Eckert. All rights reserved.
//

#import "SFCFObject.h"

SFCFVector3f SFCFMakeVector3f(float _x, float _y, float _z) { SFCFVector3f v; v.x=_x;v.y=_y;v.z=_z; return v; }

@implementation SFCFObject

-(SFCFObject*) initWithLayer:(CALayer*)layer withImage:(NSImage*)img {
	if (self = [super init]) {
		parentLayer = layer;
		sfImage = nil;
		imageStd = img;
		
		creationThread = [NSThread currentThread];
		
		mainLayer1 = [CALayer layer];
		mainLayer1.name = @"mainLayer";
		mainLayer1.bounds = CGRectMake( 0, 0, 128, 256 );
		mainLayer1.anchorPoint = CGPointMake(0.5,0);
		mainLayer1.zPosition = 0;
		mainLayer1.position = CGPointMake(0,0);
		mainLayer1.delegate = self;
		mainLayer1.opacity = 1.0;
		
		mainLayer1.shadowOpacity = 0;
		mainLayer1.shadowRadius = 10;
		
		[parentLayer addSublayer:mainLayer1];

		[self setImage:nil];
		[self redraw];
	}
	return self;
}


-(void) setPosition:(SFCFVector3f)pos fast:(bool)aniFast {
	
	if ((!aniFast) && (mainLayer1.position.y > 2000) && (pos.y < 2000)) {
		[self setPosition:pos fast:true];
		return;
	}
	
    [CATransaction flush];
	[CATransaction begin];
	if (aniFast == true) {
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
	} else {
		[CATransaction setValue:[NSNumber numberWithFloat:0.3f]
						 forKey:kCATransactionAnimationDuration];
	}
	mainLayer1.position = CGPointMake(pos.x, pos.y - [mainLayer1 bounds].size.height/2);
	mainLayer1.zPosition = pos.z - 100; // richtiges wert: 1000
	
	[CATransaction commit];
}

-(SFCFVector3f) position {
	return SFCFMakeVector3f(mainLayer1.position.x, mainLayer1.position.y, mainLayer1.zPosition);
}

-(void) setDist:(int)dist fast:(bool)aniFast {
    [CATransaction flush];
	[CATransaction begin];
	if (aniFast == true) {
		[CATransaction setValue:(id)kCFBooleanTrue
						 forKey:kCATransactionDisableActions];
	} else {
		[CATransaction setValue:[NSNumber numberWithFloat:0.3f]
						 forKey:kCATransactionAnimationDuration];
	}
	
	if (dist == 0) {
		mainLayer1.transform = CATransform3DIdentity;
	} else if (dist < 0) {
		mainLayer1.transform = CATransform3DMakeRotation(-0.95, 0, -1, 0);
	} else if (dist > 0) {
		mainLayer1.transform = CATransform3DMakeRotation(0.95, 0, -1, 0);
	}
	[CATransaction commit];

	/*/ FILTERS -- SLOW
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue
					 forKey:kCATransactionDisableActions];
	if (dist != 0) {
		mainLayer1.backgroundFilters = nil;
	} else {
		CIFilter* filter = [CIFilter filterWithName:@"CIGaussianBlur"];
		filter.name = @"myFilter";
		mainLayer1.backgroundFilters = [NSArray arrayWithObject:filter];
		[mainLayer1 setValue:[NSNumber numberWithInt:2] forKeyPath:@"backgroundFilters.myFilter.inputRadius"];
	}
	[CATransaction commit];/**/
	
	/*
	float o_alpha1 = alpha1;
	alpha1 = (dist!=0)?0.6:0.0;
	
	if (o_alpha1 != alpha1) [self redraw];/**/
}

-(void) redraw {
    [CATransaction flush];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];

	[mainLayer1 setNeedsDisplay];

    [CATransaction commit];
}

-(void) setImage: (NSImage*)img {
	NSImage* before = sfImage;
	
	if (sfImage == img) return;
	if (sfImage != nil) [sfImage release];
	if (img == nil) sfImage = nil;
	else sfImage = [img retain];
	
	//if ((sfImage != before) && (sfImage != nil)) [self redraw];
	if (sfImage != before) [self redraw];
}

-(bool) hasImage { return (sfImage != nil); }

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)cgContext;
{    
	[NSGraphicsContext saveGraphicsState];
	NSRect drawingRect = NSRectFromCGRect( CGContextGetClipBoundingBox( cgContext ) );
	NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:cgContext flipped:false];
	[NSGraphicsContext setCurrentContext:context];
	
	//[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	
	NSRect topRect, bottomRect;
	NSDivideRect(drawingRect, &topRect, &bottomRect, drawingRect.size.height/2, NSMaxYEdge);
	

	NSImage* img = imageStd;
	if (sfImage) {
		img = sfImage;
		
		// Draw Main
		[img compositeToPoint:topRect.origin operation:NSCompositeSourceOver];
		
		// Draw Mirror
		NSAffineTransform* xform = [NSAffineTransform transform];
		[xform translateXBy:0.0 yBy:bottomRect.size.height];
		[xform scaleXBy:1.0 yBy:-1.0];
		[xform concat];
		[img drawAtPoint:bottomRect.origin fromRect:rectFromSize([img size]) operation:NSCompositeSourceOver fraction:1.0];
		
		NSColor* color1 = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1.0];
		NSColor* color2 = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:.76];
		NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:color1 endingColor:color2];
		[[NSGraphicsContext currentContext] setCompositingOperation:NSCompositeSourceAtop];
		[gradient drawInRect:bottomRect angle:270];
	}
	else
	{
		[[NSColor clearColor] set]; NSRectFill(drawingRect);
	}/**/

	[NSGraphicsContext restoreGraphicsState];        
}


@end
