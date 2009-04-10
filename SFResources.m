//
//  SFResources.m
//  SilverFlow
//
//  Created by Julius Eckert on 06.05.08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "SFResources.h"

SFResources* SFRes;

@implementation SFResources

+ (id)sharedInstance {
	if (!SFRes) SFRes = [[[self class] allocWithZone:[self zone]] init];
	return SFRes;
}

- (id)init {
	if (self = [super init]) {
		
		NSString* pathToStd = [[NSBundle bundleWithIdentifier:@"com.blacktree.Quicksilver.SilverFlow"] pathForResource:@"SFStandart" ofType:@"png"];
		stdImage = [[NSImage alloc] initWithContentsOfFile:pathToStd];

	}
	return self;
}

- (NSImage*) getStandart {
	return stdImage;
}

@end
