    //
//  BaseController.m
//  twittaddict
//
//  Created by Shannon Rush on 12/23/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import "BaseController.h"
#import "twittaddictAppDelegate.h"

@implementation BaseController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    [super dealloc];
}

@end

@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end


@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
	NSUInteger count = [self count];
	for (NSUInteger i = 0; i < count; ++i) {
		int nElements = count - i;
		int n = (random() % nElements) + i;
		[self exchangeObjectAtIndex:i withObjectAtIndex:n];
	}
}

@end