//
//  FriendStatsController.m
//  twittaddict
//
//  Created by Shannon Rush on 1/6/11.
//  Copyright 2011 Rush Devo. All rights reserved.
//

#import "FriendStatsController.h"
#import "twittaddictAppDelegate.h"


@implementation FriendStatsController


- (void)viewDidAppear: (BOOL)animated {
	twittaddictAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FriendStat" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDesc];
	NSSortDescriptor *statSort = [[NSSortDescriptor alloc] initWithKey:@"percentCorrect" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:statSort]];
	[request setFetchLimit:5];	
	NSError *error;
	NSArray *stats = [context executeFetchRequest:request error:&error];
	[request release];
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
