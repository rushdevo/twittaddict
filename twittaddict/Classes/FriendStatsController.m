//
//  FriendStatsController.m
//  twittaddict
//
//  Created by Shannon Rush on 1/6/11.
//  Copyright 2011 Rush Devo. All rights reserved.
//

#import "FriendStatsController.h"
#import "twittaddictAppDelegate.h"
#import "statCell.h"

@implementation FriendStatsController

@synthesize currentUser;
@synthesize bestStats;
@synthesize statsLabel;
@synthesize statsTable;


- (void)viewDidLoad {
	bestStats = [[NSArray alloc]initWithArray:[self bestStats]];
    [super viewDidLoad];
}

#pragma mark custom methods

-(NSArray *)bestStats {
	twittaddictAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FriendStat" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDesc];
	NSSortDescriptor *statSort = [[NSSortDescriptor alloc] initWithKey:@"percentCorrect" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:statSort]];
	[request setFetchLimit:3];	
	NSError *error;
	NSArray *stats = [context executeFetchRequest:request error:&error];
	[request release];
	NSMutableArray *percents = [[NSMutableArray alloc]init];
	for (NSManagedObject *stat in stats) {
		if ([stat valueForKey:@"percentCorrect"]<100) {
			[percents addObject:[stat valueForKey:@"percentCorrect"]];
		}
	}
	if ([percents count]>0) {
		return stats;
	} else {
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		[request setEntity:entityDesc];
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"(percentCorrect = %d)", 100];
		[request setPredicate:pred];
		NSError *error;
		NSArray *stats = [context executeFetchRequest:request error:&error];
		[request release];
		NSMutableArray *perfectStats = [NSMutableArray arrayWithArray:stats];
		[perfectStats shuffle];
		return [perfectStats subarrayWithRange:NSMakeRange(0, 3)];
	}
	[percents release];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [bestStats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"customCell";
	statCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil){
		NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"statCell" owner:nil options:nil];
		for (id currentObject in nibObjects) {
			if ([currentObject isKindOfClass:[statCell class]]) {
				cell = (statCell *)currentObject;
			}
		}
	}
	NSManagedObject *stat = [bestStats objectAtIndex:[indexPath row]];
	cell.profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[stat valueForKey:@"profileImageURL"]]]];
	cell.nameLabel.text = [stat valueForKey:@"screenName"];
	cell.percentLabel.text = [NSString stringWithFormat:@"%@%%",[stat valueForKey:@"percentCorrect"]];
	return cell;
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
	[bestStats release];
	[statsLabel release];
	[statsTable release];
    [super dealloc];
}


@end
