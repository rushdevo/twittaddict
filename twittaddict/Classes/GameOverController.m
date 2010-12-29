//
//  GameOverController.m
//  twittaddict
//
//  Created by Shannon Rush on 12/27/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import "GameOverController.h"
#import "twittaddictAppDelegate.h"

@implementation GameOverController

@synthesize scoreLabel;
@synthesize messageText;
@synthesize lastScore;

- (void)viewDidLoad {
	lastScore = [self lastScore];
	scoreLabel.text = [[lastScore valueForKey:@"score"]stringValue];
    [super viewDidLoad];
}

-(IBAction)playAgain {
	
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
	return [objects objectAtIndex:0];
	[request release];
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
	[messageText release];
	[lastScore release];
    [super dealloc];
}


@end
