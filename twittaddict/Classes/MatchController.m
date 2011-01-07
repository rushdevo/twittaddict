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
@synthesize background1Image;
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
@synthesize background2Image;
@synthesize tweet1Button;
@synthesize tweet2Button;
@synthesize tweet3Button;
@synthesize userImage;
@synthesize userLabel;
@synthesize correctTweetID;


- (void)viewDidAppear: (BOOL)animated {
	score = 0;
	secondsRemaining = 60;
	tweets = [[NSMutableArray alloc]init];
	follows = [[NSMutableArray alloc]init];
	friends = [[NSMutableArray alloc]init];
	retrievedAuthID = NO;
	correctUserID = [[NSString alloc]init];
	selectedUsers = [[NSMutableArray alloc]init];
	
	if(!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey    = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;	
	}
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
	
	if (controller){
		[self presentModalViewController: controller animated: YES];
	} else {
		[_engine checkUserCredentials];
	}
}


//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
	//[_engine performSelectorOnMainThread:@selector(checkUserCredentials) withObject:nil waitUntilDone:NO];
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
	if ([error code]==-1009) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Connect" message:nil delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		[self viewDidAppear:FALSE];		
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self viewDidAppear:FALSE];
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
		[self setupRandomMode];
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
			[self setupRandomMode];
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
	gameOver.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:gameOver animated:YES];
	[gameOver release];
}

-(void)setupRandomMode {
	loadingActivity.hidden = YES;
	loadingImage.hidden = YES;
	int rand = (arc4random() % 2 ? 1 : 0);
	if (rand==0) {
		[self setupMode1];
	} else {
		[self setupMode2];
	}
}

-(void)setupMode1 {
	NSDictionary *tweet = [NSDictionary dictionaryWithDictionary:[tweets objectAtIndex:arc4random()%[tweets count]]];
	[tweets removeObject:tweet];
	[self performSelectorOnMainThread:@selector(initMode1Components:) withObject:tweet waitUntilDone:NO];
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
	[self hideMode2Components];
	[self showMode1Components];
}

-(void)hideMode1Components {
	background1Image.hidden = YES;
	tweetText.hidden = YES;
	user1Label.hidden = YES;
	user1Button.hidden = YES;
	user2Label.hidden = YES;
	user2Button.hidden = YES;
	user3Label.hidden = YES;
	user3Button.hidden = YES;
}

-(void)showMode1Components {
	background1Image.hidden = NO;
	tweetText.hidden = NO;
	user1Label.hidden = NO;
	user1Button.hidden = NO;
	user2Label.hidden = NO;
	user2Button.hidden = NO;
	user3Label.hidden = NO;
	user3Button.hidden = NO;
}

-(void)initUser:(NSDictionary *)user withButton:(SRButton *)button withLabel:(UILabel *)label {
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]]];
	[button setImage:image forState:UIControlStateNormal];
	button.userID = [user objectForKey:@"id"];
	label.text = [user objectForKey:@"screen_name"];
}

-(void)hideMode2Components {
	background2Image.hidden = YES;
	tweet1Button.hidden = YES;
	tweet2Button.hidden = YES;
	tweet3Button.hidden = YES;
	userImage.hidden = YES;
	userLabel.hidden = YES;
}

-(void)showMode2Components {
	background2Image.hidden = NO;
	tweet1Button.hidden = NO;
	tweet2Button.hidden = NO;
	tweet3Button.hidden = NO;
	userImage.hidden = NO;
	userLabel.hidden = NO;
}

-(void)setupMode2 {
	NSDictionary *tweet = [NSDictionary dictionaryWithDictionary:[tweets objectAtIndex:arc4random()%[tweets count]]];
	[tweets removeObject:tweet];
	NSDictionary *tweet2 = [NSDictionary dictionaryWithDictionary:[tweets objectAtIndex:arc4random()%[tweets count]]];
	[tweets removeObject:tweet2];
	NSDictionary *tweet3 = [NSDictionary dictionaryWithDictionary:[tweets objectAtIndex:arc4random()%[tweets count]]];
	[tweets removeObject:tweet3];
	NSMutableArray *tweetChoices = [NSMutableArray arrayWithObjects:tweet,tweet2,tweet3,nil];
	[self performSelectorOnMainThread:@selector(initMode2Components:) withObject:tweetChoices waitUntilDone:NO];
}

-(void)initMode2Components:(NSMutableArray *)tweetChoices {
	correctTweetID = [[NSString alloc]initWithString:[[tweetChoices objectAtIndex:0]objectForKey:@"tweet_id"]];
	NSDictionary *user = [[tweetChoices objectAtIndex:0]objectForKey:@"user"];
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]]];
	userImage.image = image;
	userLabel.text = [user objectForKey:@"screen_name"];
	[tweetChoices shuffle];
	[self initTweet:[tweetChoices objectAtIndex:0] withButton:tweet1Button];
	[self initTweet:[tweetChoices objectAtIndex:1] withButton:tweet2Button];
	[self initTweet:[tweetChoices objectAtIndex:2] withButton:tweet3Button];
	[self hideMode1Components];
	[self showMode2Components];
}
	 
-(void)initTweet:(NSDictionary *)tweet withButton:(SRButton *)button {
	[button setImage:nil forState:UIControlStateNormal];
	[button setTitle:[tweet objectForKey:@"text"] forState:UIControlStateNormal];
	button.tweetID = [tweet objectForKey:@"tweet_id"];
	button.userID = [[tweet objectForKey:@"user"]objectForKey:@"id"];
}

# pragma mark Game Play


-(IBAction)userSelected:(id)sender {
	if ([[sender userID] isEqualToString:correctUserID]) {
		[sender setImage:[UIImage imageNamed:@"correct.png"] forState:UIControlStateNormal];
		[self increaseScore];
	} else {
		[sender setImage:[UIImage imageNamed:@"wrong.png"] forState:UIControlStateNormal];
	}
	NSThread *gameThread = [[NSThread alloc]initWithTarget:self selector:@selector(startGameThread) object:nil];
	[gameThread start];
}

-(IBAction)tweetSelected:(id)sender {
	[sender setTitle:@"" forState:UIControlStateNormal];
	if ([[sender tweetID] isEqualToString:correctTweetID]) {
		[sender setImage:[UIImage imageNamed:@"correct.png"] forState:UIControlStateNormal];
		[self increaseScore];
	} else {
		[sender setImage:[UIImage imageNamed:@"wrong.png"] forState:UIControlStateNormal];
	}
	NSThread *gameThread = [[NSThread alloc]initWithTarget:self selector:@selector(startGameThread) object:nil];
	[gameThread start];
}
		 
-(void)increaseScore {
	score += 10;
	scoreLabel.text = [NSString stringWithFormat:@"%d",score];
}

-(void)saveFriendStat:(NSString *)userID withValue:(BOOL)correct {
//	twittaddictAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//	NSManagedObjectContext *context = [appDelegate managedObjectContext];
//	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FriendStat" inManagedObjectContext:context];
//	NSFetchRequest *request = [[NSFetchRequest alloc] init];
//	[request setEntity:entityDesc];
//	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(userID = %@)", userID];
//	[request setPredicate:pred];
//	NSError *error;
//	NSArray *stats = [context executeFetchRequest:request error:&error];
//	[request release];
//	if ([stats count]>0) {
//		// update record
//		NSDictionary *stat = [stats objectAtIndex:0];
//		[stat setValue:[stat objectForKey:@"attempts"]+1 forKey:@"attempts"];
//		if (correct) {
//			[stat setValue:[stat objectForKey:@"correct"]+1 forKey:@"correct"];
//		}
//		[stat setValue:[self percentCorrect:[stat objectForKey:@"correct"] withAttempts:[stat objectForKey:@"attempts"]] forKey:@"percentCorrect"];
//		NSError *error;
//		[context save:&error];
//	} else {
//		//create record
//		NSManagedObject *statObject = [NSEntityDescription
//										insertNewObjectForEntityForName:@"FriendStat" 
//										inManagedObjectContext:context];
//		[statObject setValue:userID forKey:@"userID"];
//		[statObject setValue:1 forKey:@"attempts"];
//		if (correct) {
//			[statObject setValue:1 forKey:@"correct"];
//		} else {
//			[statObject setValue:0 forKey:@"correct"];
//		}
//		[statObject setValue:[self percentCorrect:[statObject objectForKey:@"correct"] withAttempts:[statObject objectForKey:@"attempts"]] forKey:@"percentCorrect"];
//		NSError *error;
//		[context save:&error];
//	}
}

-(NSDecimal *)percentCorrect:(NSDecimal *)correct withAttempts:(NSDecimal *)attempts {
	NSDecimalNumberHandler *roundingBehavior = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundDown scale:2];
	return [correct decimalNumberByDividingBy:attempts withBehavior:roundingBehavior];
}

-(void) startGameThread {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	[self setupRandomMode];
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
	[background1Image release];
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
	[background2Image release];
	[tweet1Button release];
	[tweet2Button release];
	[tweet3Button release];
	[userImage release];
	[userLabel release];
	[correctTweetID release];
    [super dealloc];
}


@end