//
//  SFResources.h
//  SilverFlow
//
//  Created by Julius Eckert on 06.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SFResources : NSObject {
	NSImage* stdImage;
}

+ (id)sharedInstance;
- (NSImage*) getStandart;

@end
