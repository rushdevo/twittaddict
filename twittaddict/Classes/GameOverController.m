//
//  GameOverController.m
//  twittaddict
//
//  Created by Shannon Rush on 12/27/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import "GameOverController.h"
#import "twittaddictAppDelegate.h"
#import "MatchController.h"
#import "FriendStatsController.h"

@implementation GameOverController

@synthesize scoreLabel;
@synthesize lastScore;
@synthesize highScores;
@synthesize highScoreTable;
@synthesize matchView;

- (void)viewDidLoad {
	self.wantsFullScreenLayout = YES;
	lastScore = [self lastScore];
	highScores = [[NSArray alloc]initWithArray:[self highScores]];
	scoreLabel.text = [[lastScore valueForKey:@"score"]stringValue];
	if ([twittaddictAppDelegate gameCenter]) {
		leaderboardButton.hidden = NO;
		achievementButton.hidden = NO;
		if (self.matchView.newAchievements) {
			newAchievementButton.hidden = NO;
		}
	}
    [super viewDidLoad];
}

-(IBAction)playAgain {
	MatchController *match = [[MatchController alloc] initWithNibName:@"MatchController" bundle:[NSBundle mainBundle]];
	match.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:match animated:YES];
	[match release];
}

-(NSDictionary *)lastScore {
	twittaddictAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Score" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDesc];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(gameMode = %@)", @"Match"];
	NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:dateSort]];
	[request setFetchLimit:1];	
	[request setPredicate:pred];
	NSError *error;
	NSArray *objects = [context executeFetchRequest:request error:&error];
	[request release];
	[dateSort release];
	return [objects objectAtIndex:0];
}

-(NSArray *)highScores {
	twittaddictAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Score" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDesc];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(gameMode = %@)", @"Match"];
	NSSortDescriptor *scoreSort = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO];
	[request setSortDescriptors:[NSArray arrayWithObject:scoreSort]];
	[request setFetchLimit:5];	
	[request setPredicate:pred];
	NSError *error;
	NSArray *objects = [context executeFetchRequest:request error:&error];
	[request release];
	[scoreSort release];
	return objects;
}

-(IBAction)showStats {
	FriendStatsController *statsView = [[FriendStatsController alloc] initWithNibName:@"FriendStatsController" bundle:[NSBundle mainBundle]];
	statsView.modalTransitionStyle = UIModalTransitionStylePartialCurl;
	statsView.currentUser = self.matchView.currentUser;
	[self presentModalViewController:statsView animated:YES];
	[statsView release];
}

#pragma mark GameKit

-(IBAction)showLeaderboard {
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != nil) {
        leaderboardController.leaderboardDelegate = self;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController: leaderboardController animated: YES];
    }
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)showAchievements {
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
    if (achievements != nil) {
        achievements.achievementDelegate = self;
		achievements.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController: achievements animated: YES];
    }
    [achievements release];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [highScores count];
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	NSDictionary *highScore = [highScores objectAtIndex:[indexPath row]];
	if (highScore==lastScore) {
		cell.textLabel.textColor = [UIColor colorWithRed:110.0f/255.0f green:180.0f/255.0f blue:205.0f/255.0f alpha:1.0];
	} else {
		cell.textLabel.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0];
	}
	cell.textLabel.text = [NSString stringWithFormat:@"%d. %@",[indexPath row]+1,[[highScore valueForKey:@"score"]stringValue]];
	cell.textLabel.font = [UIFont fontWithName:@"Marker Felt" size:20.0f];
	return cell;
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
	[scoreLabel release];
	[lastScore release];
	[highScores release];
	[highScoreTable release];
	[matchView release];
    [super dealloc];
}


@end
