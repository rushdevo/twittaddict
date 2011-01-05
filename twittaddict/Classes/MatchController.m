//
//  MatchController.m
//  twittaddict
//
//  Created by Shannon Rush on 12/19/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import "MatchController.h"
#import "SA_OAuthTwitterEngine.h" 
#import "twittaddictAppDelegate.h"
#import "GameOverController.h"

#define kOAuthConsumerKey @"fzhClftPYrGwJGpo86xeGw"         
#define kOAuthConsumerSecret @"Np92rlHsIy4IV4FO7ELPw6IwM16QzTNAUeZkdrrsOUA"       

@implementation MatchController

@synthesize tweets;
@synthesize follows;
@synthesize authID;
@synthesize friends;
@synthesize scoreLabel;
@synthesize timerLabel;
@synthesize user1Button;
@synthesize user2Button;
@synthesize user3Button;
@synthesize user1Label;
@synthesize user2Label;
@synthesize user3Label;
@synthesize tweetText;
@synthesize selectedUsers;
@synthesize correctUserID;
@synthesize loadingActivity;
@synthesize loadingImage;


- (void)viewDidAppear: (BOOL)animated {
	
	if(!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey    = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;	
	}
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
	
	if (controller){
		[self presentModalViewController: controller animated: YES];
	}
	
	score = 0;
	secondsRemaining = 60;
	tweets = [[NSMutableArray alloc]init];
	follows = [[NSMutableArray alloc]init];
	friends = [[NSMutableArray alloc]init];
	retrievedAuthID = NO;
	correctUserID = [[NSString alloc]init];
	selectedUsers = [[NSMutableArray alloc]init];
	[_engine checkUserCredentials];
}


//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
	for(NSDictionary *status in statuses) {
		if (![[[status objectForKey:@"user"]objectForKey:@"id"] isEqualToString:authID]) {
			NSMutableDictionary *tweet = [[NSMutableDictionary alloc]init];
			[tweet setObject:[status objectForKey:@"id"] forKey:@"tweet_id"];
			[tweet setObject:[status objectForKey:@"text"] forKey:@"text"];
			[tweet setObject:[status objectForKey:@"user"] forKey:@"user"];
			[tweets addObject:tweet];
			[tweet release];
		}
	}
	if ([tweets count] > 0 && [friends count]>0) {
		[self startTimer];
		[self setupMode1];
	}
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
	if (!retrievedAuthID) {
		authID = [[NSString alloc]initWithString:[[userInfo objectAtIndex:0]objectForKey:@"id"]];
		retrievedAuthID = YES;
		[_engine getFriendIDsFor:[[userInfo objectAtIndex:0]objectForKey:@"screen_name"]];
		[_engine getFollowedTimelineSinceID:0 startingAtPage:0 count:200];
	} else {
		[friends setArray:userInfo];
		if ([tweets count] > 0 && [friends count] > 0) {
			[self startTimer];
			[self setupMode1];
		}
	}
}

- (void)socialGraphInfoReceived:(NSArray *)socialGraphInfo forRequest:(NSString *)connectionIdentifier {
	NSMutableArray *friendIDs = [NSMutableArray arrayWithArray:[[socialGraphInfo objectAtIndex:0]objectForKey:@"ids"]];
	[friendIDs shuffle];
	NSMutableArray *friendStringIDs = [[NSMutableArray alloc]init];
	if ([friendIDs count] > 100) {
		friendIDs = [NSMutableArray arrayWithArray:[friendIDs subarrayWithRange:NSMakeRange(0, 99)]];
	} 
	for (NSString *friendID in friendIDs) {
		[friendStringIDs addObject:friendID];
	}
	NSMutableString *friendString = [[NSMutableString alloc]init];
	for (NSString *friendID in friendStringIDs) {
		[friendString appendString:[NSString stringWithFormat:@"%@,", friendID]];
	}
	[friendStringIDs release];
	[_engine getBulkUserInformationFor:friendString];
	[friendString release];
}

#pragma mark Game Setup

-(void) startTimer {
	NSThread* timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTimerThread) object:nil]; //Create a new thread
	[timerThread start]; 
}

-(void) startTimerThread {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	[[NSTimer scheduledTimerWithTimeInterval: 1.0
									  target: self
									selector: @selector(countdown:)
									userInfo: nil
									 repeats: YES] retain];
	
	[runLoop run];
	[pool release];
}

- (void)countdown:(NSTimer *)timer {
	if (secondsRemaining > 0) {
		timerLabel.text = [NSString stringWithFormat:@"%d", secondsRemaining];
		secondsRemaining -= 1;
	} else {
		[self saveScore];
		[self performSelectorOnMainThread:@selector(presentGameOver) withObject:nil waitUntilDone:NO];
	}
}

-(void)presentGameOver {
	GameOverController *gameOver = [[GameOverController alloc] initWithNibName:@"GameOverController" bundle:[NSBundle mainBundle]];
	[self presentModalViewController:gameOver animated:YES];
	[gameOver release];
}

-(void)setupMode1 {
	if ([tweets count]==0) {
		[_engine getFollowedTimelineSinceID:0 startingAtPage:0 count:200];
	} else {
		NSDictionary *tweet = [NSDictionary dictionaryWithDictionary:[tweets objectAtIndex:arc4random()%[tweets count]]];
		[tweets removeObject:tweet];
		[self performSelectorOnMainThread:@selector(initMode1Components:) withObject:tweet waitUntilDone:NO];
	}
	loadingActivity.hidden = YES;
	loadingImage.hidden = YES;
}				

-(void)initMode1Components:(NSDictionary *)tweet {
	tweetText.text = [tweet valueForKey:@"text"];
	correctUserID = [[NSString alloc]initWithString:[[tweet objectForKey:@"user"]valueForKey:@"id"]];
	[friends shuffle];
	NSMutableArray *users = [[NSMutableArray alloc]initWithObjects:[tweet objectForKey:@"user"],[friends objectAtIndex:0],[friends objectAtIndex:1], nil];
	[users shuffle];
	[self initUser:[users objectAtIndex:0] withButton:user1Button withLabel:user1Label];
	[self initUser:[users objectAtIndex:1] withButton:user2Button withLabel:user2Label];
	[self initUser:[users objectAtIndex:2] withButton:user3Button withLabel:user3Label];
}

-(void)initUser:(NSDictionary *)user withButton:(SRButton *)button withLabel:(UILabel *)label {
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]]];
	[button setImage:image forState:UIControlStateNormal];
	button.userID = [user objectForKey:@"id"];
	label.text = [user objectForKey:@"screen_name"];
}


-(void)setupMode2 {
	
}

# pragma mark Game Play


-(IBAction)userSelected:(id)sender {
	if ([[sender userID] isEqualToString:correctUserID]) {
		[sender setImage:[UIImage imageNamed:@"correct.png"] forState:UIControlStateNormal];
		score += 10;
		scoreLabel.text = [NSString stringWithFormat:@"%d",score];
	} else {
		[sender setImage:[UIImage imageNamed:@"wrong.png"] forState:UIControlStateNormal];
	}
	NSThread *gameThread = [[NSThread alloc]initWithTarget:self selector:@selector(startGameThread) object:nil];
	[gameThread start];
}

-(void) startGameThread {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	[self setupMode1];
	[runLoop run];
	[pool release];
}



-(void)saveScore {
	twittaddictAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSManagedObject *scoreObject = [NSEntityDescription
									   insertNewObjectForEntityForName:@"Score" 
									   inManagedObjectContext:context];
	[scoreObject setValue:[NSNumber numberWithInt:score] forKey:@"score"];
	[scoreObject setValue:@"Match" forKey:@"gameMode"];
	[scoreObject setValue:[NSDate date] forKey:@"timestamp"];
	NSError *error;
	[context save:&error];
	
}

# pragma mark memory management

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
	[tweets release];
	[follows release];
	[authID release];
	[friends release];
	[_engine release];
	[selectedUsers release];
	[scoreLabel release];
	[timerLabel release];
	[user1Button release];
	[user2Button release];
	[user3Button release];
	[user1Label release];
	[user2Label release];
	[user3Label release];
	[tweetText release];
	[correctUserID release];
	[loadingActivity release];
	[loadingImage release];
    [super dealloc];
}


@end