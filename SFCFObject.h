//
//  SFCFObject.h
//  SilverFlow
//
//  Created by Julius Eckert on 02.02.08.
//  Copyright 2008 Julius Eckert. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

typedef struct _SFCFVector3f { float x, y, z; } SFCFVector3f;
SFCFVector3f SFCFMakeVector3f(float _x, float _y, float _z);

@interface SFCFObject : NSObject {
	CALayer* parentLayer;
	NSThread* creationThread;
	
	CALayer* mainLayer1;
	
	NSImage* imageStd;
	NSImage* sfImage;
	
	float alpha1;
}

-(SFCFObject*) initWithLayer:(CALayer*)layer withImage:(NSImage*)img;
-(void) redraw;

-(void) setPosition:(SFCFVector3f)pos fast:(bool)aniFast;
-(SFCFVector3f) position;
-(void) setDist:(int)dist fast:(bool)aniFast;

-(void) setImage: (NSImage*)img;
-(bool) hasImage;

@end
