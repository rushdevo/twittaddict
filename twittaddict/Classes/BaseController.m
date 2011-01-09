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

- (void) deleteAllObjects: (NSString *) entityDescription  {
	twittaddictAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
	
	
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityDescription);
    }
    if (![context save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
	
}


- (void)dealloc {
    [super dealloc];
}

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


@end
