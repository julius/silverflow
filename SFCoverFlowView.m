//
//  SFCoverFlowView.m
//  SilverFlow
//
//  Created by Julius Eckert on 05.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SFCoverFlowView.h"


@implementation SFCoverFlowView
@synthesize soAction, soIndirect;

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setLayer:[CALayer layer]];
		[self setWantsLayer:true];
		
		//[[self layer] setBounds:NSRectToCGRect([self frame])];
		[[self layer] setFrame:NSRectToCGRect([self frame])];
		[[self layer] setDelegate:self];
		CATransform3D sublayerTransform = CATransform3DIdentity; 
		sublayerTransform.m34 = 1. / -340.;
		[[self layer] setSublayerTransform:sublayerTransform];
		[[self layer] setNeedsDisplay];
		
		//[self layer].edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
		//[self layer].minificationFilter = kCAFilterNearest;
		//[self layer].magnificationFilter = kCAFilterNearest; 
		

		coverFlow = [[SFCoverFlow alloc] initWithLayer:[self layer]];
		[self setupLayers];
		
		soAction = [[SFSelectorObject alloc] initWithLayer:[self layer] asSelector:2];
		soIndirect = [[SFSelectorObject alloc] initWithLayer:[self layer] asSelector:3];
    }
    return self;
}

- (void)setSelector:(int)sel {
	if (sel == 1) dof.opacity = 1;
	else dof.opacity = 0;

	[soAction setCurrentSelector:sel];
	[soIndirect setCurrentSelector:sel];
	[coverFlow setSelector:sel];
}


- (void)setText:(NSString*)text details:(NSString*)details {
    [CATransaction flush];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
 	[textLayer setString:text];
	[textLayer2 setString:details];
	[CATransaction commit];	

	textLayer3.opacity = 0.05;
}




- (void)setupLayers {
	textLayer = [CATextLayer layer];
	textLayer.name = @"textLayer";
	textLayer.string = @"";
	textLayer.font                  = [NSFont boldSystemFontOfSize:22.0];
	textLayer.fontSize              = 22;
	textLayer.bounds				= CGRectMake( 0, 0, 400, 40 );
	textLayer.alignmentMode         = kCAAlignmentCenter;
	textLayer.anchorPoint			= CGPointMake(0.5, 0.5);
	textLayer.position				= CGPointMake([[self layer] frame].size.width/2, 30);
	textLayer.foregroundColor		= CGColorCreateGenericRGB(255, 255, 255, 255);
	textLayer.zPosition = 0;
	textLayer.opacity = 1.0;
	[[self layer] addSublayer:textLayer];
	
	textLayer2 = [CATextLayer layer];
	textLayer2.name = @"textLayer";
	textLayer2.string = @"";
	textLayer2.font                  = [NSFont boldSystemFontOfSize:12.0];
	textLayer2.fontSize              = 12;
	textLayer2.bounds				= CGRectMake( 0, 0, 400, 40 );
	textLayer2.alignmentMode         = kCAAlignmentCenter;
	textLayer2.anchorPoint			= CGPointMake(0.5, 0.5);
	textLayer2.position				= CGPointMake([[self layer] frame].size.width/2, 4);
	textLayer2.foregroundColor		= CGColorCreateGenericRGB(255, 255, 255, 255);
	textLayer2.zPosition = 0;
	textLayer2.opacity = 1.0;
	[[self layer] addSublayer:textLayer2];
	
	textLayer3 = [CATextLayer layer];
	textLayer3.name = @"textLayer";
	textLayer3.string = @"SilverFlow";
	textLayer3.font                  = [NSFont boldSystemFontOfSize:60.0];
	textLayer3.fontSize              = 60;
	textLayer3.shadowOffset          = CGSizeMake ( 0, 0 );
	textLayer3.shadowOpacity         = 1.0;
	textLayer3.shadowColor			= CGColorCreateGenericRGB(255, 255, 255, 255);
	textLayer3.shadowRadius			= 24;
	textLayer3.bounds				= CGRectMake( 0, 0, 650, 140 );
	textLayer3.alignmentMode         = kCAAlignmentCenter;
	textLayer3.anchorPoint			= CGPointMake(0.5, 0.5);
	textLayer3.position				= CGPointMake([[self layer] frame].size.width/2, [[self layer] frame].size.height/2-40);
	textLayer3.foregroundColor		= CGColorCreateGenericRGB(255, 255, 255, 255);
	textLayer3.zPosition = -250;
	textLayer3.opacity = 0.85;
	textLayer3.transform = CATransform3DMakeScale(1,1.2,1);
	[[self layer] addSublayer:textLayer3];

	[textLayer setTruncationMode:kCATruncationMiddle];
	[textLayer2 setTruncationMode:kCATruncationMiddle];
	//inited = false;
	
	
	
	// ---------- Depth of Field Effect ---------------
	dof = [CALayer layer];
	dof.name = @"dof";
	dof.bounds = CGRectMake(0, 0, 1800, 1000);
	dof.position = CGPointMake(-100, -100);
	dof.zPosition = -250;
	dof.delegate = self;
	[[self layer] addSublayer:dof];
	[dof setNeedsDisplay];
	
	//*
	CIFilter* filter = [CIFilter filterWithName:@"CIGaussianBlur"];
	filter.name = @"myFilter";
	dof.backgroundFilters = [NSArray arrayWithObject:filter];
	[dof setValue:[NSNumber numberWithInt:2] forKeyPath:@"backgroundFilters.myFilter.inputRadius"];
	 /**/
}

- (void)dofRedraw {
    [CATransaction flush];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
	
	[dof setNeedsDisplay];
	
    [CATransaction commit];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)cgContext;
{
	NSLog(@"draw");
	[NSGraphicsContext saveGraphicsState];
	NSRect drawingRect = NSRectFromCGRect( CGContextGetClipBoundingBox( cgContext ) );
	NSGraphicsContext* context = [NSGraphicsContext graphicsContextWithGraphicsPort:cgContext flipped:NO];
	[NSGraphicsContext setCurrentContext:context];
	
	if ([[layer name] isEqualToString:@"dof"]) {
		/*
		NSRect leftRect, rightRect;
		NSDivideRect(drawingRect, &leftRect, &rightRect, 600, NSMaxXEdge);
		
		NSColor* color1 = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:.1];
		NSColor* color2 = [NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1];
		NSGradient* gradient = [[NSGradient alloc] initWithStartingColor:color1 endingColor:color2];
		[gradient drawInRect:rightRect angle:180];
		[gradient drawInRect:leftRect angle:0];
		
		/**/
	} else {
		[[NSColor blackColor] setFill];
		NSRectFillUsingOperation(drawingRect, NSCompositeCopy);
	}
	[NSGraphicsContext restoreGraphicsState];        
}	

- (SFCoverFlow*) coverflow { return coverFlow; }

@end
