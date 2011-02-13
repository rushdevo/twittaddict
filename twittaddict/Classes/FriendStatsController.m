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

@synthesize currentUser;
@synthesize statsLabel;
@synthesize bffImage;
@synthesize bffLabel;

-(void)viewDidLoad {
	self.wantsFullScreenLayout = YES;
	statsLabel.text = [NSString stringWithFormat:@"%@'s Twitter BFF is...", [currentUser objectForKey:@"screen_name"]];
	[self loadBFF];
	[super viewDidLoad];
}

#pragma mark custom methods

-(void)loadBFF {
	twittaddictAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FriendStat" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDesc];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(percentCorrect = %d)", 100];
	[request setPredicate:pred];
	NSError *error;
	NSArray *friends = [context executeFetchRequest:request error:&error];
	[request release];
	if ([friends count]>0) {
		NSMutableArray *perfectFriends = [NSMutableArray arrayWithArray:friends];
		[perfectFriends shuffle];
		NSManagedObject *bff = [perfectFriends objectAtIndex:0];
		bffImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[bff valueForKey:@"profileImageURL"]]]];
		bffLabel.text = [bff valueForKey:@"screenName"];
	} else {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:entityDesc];
		NSSortDescriptor *statSort = [[NSSortDescriptor alloc] initWithKey:@"percentCorrect" ascending:NO];
		[request setSortDescriptors:[NSArray arrayWithObject:statSort]];
		[request setFetchLimit:1];	
		NSError *error;
		NSArray *friends = [context executeFetchRequest:request error:&error];
		if ([friends count]>0) {
			NSManagedObject *bff = [friends objectAtIndex:0];
			bffImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[bff valueForKey:@"profileImageURL"]]]];
			bffLabel.text = [bff valueForKey:@"screenName"];
		}
		[request release];
		[statSort release];
	}
}

#pragma mark memory management

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
	[currentUser release];
	[statsLabel release];
	[bffImage release];
	[bffLabel release];
    [super dealloc];
}


@end
