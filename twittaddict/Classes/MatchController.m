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
#import <GameKit/GameKit.h>

#define kOAuthConsumerKey @"fzhClftPYrGwJGpo86xeGw"         
#define kOAuthConsumerSecret @"Np92rlHsIy4IV4FO7ELPw6IwM16QzTNAUeZkdrrsOUA"       

@implementation MatchController

@synthesize newAchievements;
@synthesize tweets;
@synthesize backupTweets;
@synthesize follows;
@synthesize currentUser;
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
@synthesize gameThread;
@synthesize background2Image;
@synthesize tweet1Button;
@synthesize tweet2Button;
@synthesize tweet3Button;
@synthesize userImage;
@synthesize userLabel;
@synthesize correctTweetID;
@synthesize mode1InstructionImage;
@synthesize mode2InstructionImage;

- (void)viewDidAppear: (BOOL)animated {
	newAchievements = NO;
	score = 0;
	correctInARow = 0;
	attempted = 0;
	scoreSaved = NO;
	secondsRemaining = 60;
	instructMode1 = 0;
	instructMode2 = 0;
	tweets = [[NSMutableArray alloc]init];
	follows = [[NSMutableArray alloc]init];
	retrievedCurrentUser = NO;
	correctUserID = [[NSMutableString alloc]init];
	correctTweetID = [[NSMutableString alloc]init];
	selectedUsers = [[NSMutableArray alloc]init];
	tweetText.font = [UIFont fontWithName:@"Arial" size:14.0f];
	[tweet1Button setTitle:@"" forState:UIControlStateHighlighted];
	[tweet2Button setTitle:@"" forState:UIControlStateHighlighted];
	[tweet3Button setTitle:@"" forState:UIControlStateHighlighted];

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
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
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
	if ([error code]==-1009) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Connect" message:nil delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if ([error code]==400) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We're Sorry!" message:@"Twitter is experiencing problems.  Please try again later!" delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else if ([error code]==401) {
		[_engine clearAccessToken];
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey    = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;	
		UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
		[self presentModalViewController: controller animated: YES];
	} else {
		[self viewDidAppear:FALSE];		
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self viewDidAppear:FALSE];
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier {
	for(NSDictionary *status in statuses) {
		if (![[[status objectForKey:@"user"]objectForKey:@"id"] isEqualToString:[currentUser objectForKey:@"id"]]) {
			NSMutableDictionary *tweet = [[NSMutableDictionary alloc]init];
			[tweet setObject:[status objectForKey:@"id"] forKey:@"tweet_id"];
			[tweet setObject:[status objectForKey:@"text"] forKey:@"text"];
			[tweet setObject:[status objectForKey:@"user"] forKey:@"user"];
			[tweets addObject:tweet];
			[tweet release];
		}
	}
	backupTweets = [[NSMutableArray alloc]initWithArray:tweets];
	if ([tweets count] > 0 && [[twittaddictAppDelegate friends] count] > 3) {
		[self hideLoading];
	}
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
	if (!retrievedCurrentUser) {
		currentUser = [[NSDictionary alloc]initWithDictionary:[userInfo objectAtIndex:0]];
		retrievedCurrentUser = YES;
		[_engine getFriendIDsFor:[[userInfo objectAtIndex:0]objectForKey:@"screen_name"]];
		[_engine getFollowedTimelineSinceID:0 startingAtPage:0 count:200];
	} else {
		[self performSelectorInBackground:@selector(initFriends:) withObject:userInfo];
		while ([[twittaddictAppDelegate friends]count]<4) {
			NSLog([NSString stringWithFormat:@"%i",[[twittaddictAppDelegate friends]count]]);
		}
		if ([tweets count] > 0 && [[twittaddictAppDelegate friends] count] > 3) {
			[self hideLoading];
		}
	}
}

-(void)initFriends:(NSArray *)userInfo {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	for (NSDictionary *user in userInfo) {
		if (![self userInFriends:[user objectForKey:@"id"]]) {
			[self addUserToFriends:user];
		}
	}
	[runLoop run];
	[pool release];
}

-(void)friendsFromTweets:(NSMutableArray *)tweetArray {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	for (NSDictionary *tweet in tweetArray) {
		if (![self userInFriends:[[tweet objectForKey:@"user"]objectForKey:@"id"]]) {
			[self addUserToFriends:[tweet objectForKey:@"user"]];
		}
	}
	[runLoop run];
	[pool release];
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

-(BOOL)userInFriends:(NSString *)userID {
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"id", userID];
	NSArray *foundFriends = [[twittaddictAppDelegate friends] filteredArrayUsingPredicate:pred];
	if ([foundFriends count]>0) {
		return YES;
	} else {
		return NO;
	}
}

-(void)addUserToFriends:(NSDictionary *)user {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:[user objectForKey:@"id"],@"id",
									   [user objectForKey:@"screen_name"],@"screen_name",
									   [user objectForKey:@"profile_image_url"],@"profile_image_url",
									   [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]]],@"profile_image",
									   nil];
	[[twittaddictAppDelegate friends] insertObject:dictionary atIndex:0];
}

-(NSDictionary *)getUserFromFriends:(NSDictionary *)user {
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@", @"id", [user objectForKey:@"id"]];
	NSArray *foundFriends = [[twittaddictAppDelegate friends] filteredArrayUsingPredicate:pred];
	if ([foundFriends count]>0) {
		return [foundFriends objectAtIndex:0];
	} else {
		[self addUserToFriends:user];
		return [[twittaddictAppDelegate friends]objectAtIndex:0];
	}
}

#pragma mark Game Setup

-(void)hideLoading {
	loadingActivity.hidden = YES;
	if (!loadingImage.hidden) {
		playButton.hidden = NO;
	}
}

-(IBAction)startGame {
	loadingActivity.hidden = YES;
	playButton.hidden = YES;
	loadingImage.hidden = YES;
	[self startTimer];
	[self setupRandomMode];
}

-(void) startTimer {
	NSThread *timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(startTimerThread) object:nil]; //Create a new thread
	[timerThread start]; 
	[timerThread release];
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
	} else if (!scoreSaved) {
		[self saveScore];
		[self performSelectorOnMainThread:@selector(presentGameOver) withObject:nil waitUntilDone:NO];
	}
}

-(void)presentGameOver {
	GameOverController *gameOver = [[GameOverController alloc] initWithNibName:@"GameOverController" bundle:[NSBundle mainBundle]];
	gameOver.matchView = self;
	gameOver.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:gameOver animated:YES];
	[gameOver release];
}

-(void)setupRandomMode {
	playButton.hidden = YES;
	int rand = (arc4random() % 2 ? 1 : 0);
	if (rand==0) {
		[self setupMode1];
	} else {
		[self setupMode2];
	}
}

-(void)setupMode1 {
	[self enableUserButtons];
	NSDictionary *tweet = [self randomTweet];
	[tweets removeObject:tweet];
	[self performSelectorOnMainThread:@selector(initMode1Components:) withObject:tweet waitUntilDone:NO];
	if (instructMode1 < 3) {
		background1Image.hidden = YES;
		mode1InstructionImage.hidden = NO;
		[self increaseInstructionView:@"mode1"];
	}
}

-(NSDictionary *)randomTweet {
	if ([tweets count]==0) {
		[tweets setArray:backupTweets];
	}
	return [tweets objectAtIndex:arc4random()%[tweets count]];
}

-(void)increaseInstructionView:(NSString *)mode {
	if ([mode isEqualToString:@"mode1"]) {
		instructMode1 += 1;
	} else if ([mode isEqualToString:@"mode2"]) {
		instructMode2 += 1;
	}
}

-(void)initMode1Components:(NSDictionary *)tweet {
	tweetText.text = [tweet valueForKey:@"text"];
	NSDictionary *correctUser = [self getUserFromFriends:[tweet	objectForKey:@"user"]];
	[correctUserID setString:[correctUser objectForKey:@"id"]];
	[[twittaddictAppDelegate friends] shuffle];
	NSMutableArray *users = [self userChoices:correctUser];
	[users shuffle];
	[self initUser:[users objectAtIndex:0] withButton:user1Button withImage:user1Image withLabel:user1Label];
	[self initUser:[users objectAtIndex:1] withButton:user2Button withImage:user2Image withLabel:user2Label];
	[self initUser:[users objectAtIndex:2] withButton:user3Button withImage:user3Image withLabel:user3Label];
	[self hideMode2Components];
	[self showMode1Components];
}

-(void)initUser:(NSDictionary *)user withButton:(SRButton *)button withImage:(UIImageView *)imageView withLabel:(UILabel *)label {
	imageView.image = [user objectForKey:@"profile_image"];
	label.text = [user objectForKey:@"screen_name"];
	if ([[user objectForKey:@"id"]isEqualToString:correctUserID]) {
		[button setImage:[UIImage imageNamed:@"correct.png"] forState:UIControlStateHighlighted];
	} else {
		[button setImage:[UIImage imageNamed:@"wrong.png"] forState:UIControlStateHighlighted];
	}
	[self initButton:button withUser:user];
}

-(NSMutableArray *)userChoices:(NSDictionary *)correctUser {
	NSMutableArray *userChoices = [NSMutableArray arrayWithObject:correctUser];
	while ([userChoices count]<3) {
		NSDictionary *user = [[twittaddictAppDelegate friends] objectAtIndex:arc4random()%[[twittaddictAppDelegate friends] count]];
		if (![userChoices containsObject:user]) {
			[userChoices addObject:user];
		}
	}
	return userChoices;
}

-(void)hideMode1Components {
	background1Image.hidden = YES;
	mode1InstructionImage.hidden = YES;
	tweetText.hidden = YES;
	user1Label.hidden = YES;
	user1Button.hidden = YES;
	user2Label.hidden = YES;
	user2Button.hidden = YES;
	user3Label.hidden = YES;
	user3Button.hidden = YES;
	user1Image.hidden = YES;
	user2Image.hidden = YES;
	user3Image.hidden = YES;
	
}

-(void)showMode1Components {
	UIColor *color = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0];
	user1Label.textColor = color;
	user2Label.textColor = color;
	user3Label.textColor = color;
	background1Image.hidden = NO;
	tweetText.hidden = NO;
	user1Label.hidden = NO;
	user1Button.hidden = NO;
	user2Label.hidden = NO;
	user2Button.hidden = NO;
	user3Label.hidden = NO;
	user3Button.hidden = NO;
	user1Image.hidden = NO;
	user2Image.hidden = NO;
	user3Image.hidden = NO;
}

-(void)hideMode2Components {
	background2Image.hidden = YES;
	mode2InstructionImage.hidden = YES;
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
	[self enableTweetButtons];
	NSMutableArray *choices = [self tweetChoices];
	[self performSelectorOnMainThread:@selector(initMode2Components:) withObject:choices waitUntilDone:NO];
	if (instructMode2 < 3) {
		background2Image.hidden = YES;
		mode2InstructionImage.hidden = NO;
		[self increaseInstructionView:@"mode2"];
	}
}

-(NSMutableArray *)tweetChoices {
	NSDictionary *correctChoice = [self randomTweet];
	NSString *userID = [[correctChoice objectForKey:@"user"]objectForKey:@"id"];
	NSMutableArray *choices = [NSMutableArray arrayWithObject:correctChoice];
	[tweets removeObject:correctChoice];
	while ([choices count]<3) {	
		NSDictionary *choice = [self randomTweet];
		if (![[[choice objectForKey:@"user"]objectForKey:@"id"]isEqualToString:userID]) {
			[choices addObject:choice];
			[tweets removeObject:choice];
		} 
	}
	return choices;
}

-(void)initMode2Components:(NSMutableArray *)tweetChoices {
	[correctTweetID setString:[[tweetChoices objectAtIndex:0]objectForKey:@"tweet_id"]];
	NSDictionary *user = [self getUserFromFriends:[[tweetChoices objectAtIndex:0]objectForKey:@"user"]];	
	userImage.image = [user objectForKey:@"profile_image"];
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
	if ([[tweet objectForKey:@"tweet_id"]isEqualToString:correctTweetID]) {
		[button setImage:[UIImage imageNamed:@"correct.png"] forState:UIControlStateHighlighted];
	} else {
		[button setImage:[UIImage imageNamed:@"wrong.png"] forState:UIControlStateHighlighted];
	}
	[self initButton:button withUser:[tweet objectForKey:@"user"]];
}

-(void)initButton:(SRButton *)button withUser:(NSDictionary *)user {	
	button.userID = [user objectForKey:@"id"];
	button.screenName = [user objectForKey:@"screen_name"];
	button.profileImageURL = [user objectForKey:@"profile_image_url"];
}
					   

# pragma mark Game Play


-(IBAction)userSelected:(id)sender {
	[self disableUserButtons];
	attempted += 1;
	if ([[sender userID] isEqualToString:correctUserID]) {
		[self answerCorrect:sender];
	} else {
		[self answerWrong:sender];
	}
	[self setupRandomMode];
}

-(void)disableUserButtons {
	user1Button.enabled = NO;
	user2Button.enabled = NO;
	user3Button.enabled = NO;
}

-(void)enableUserButtons {
	user1Button.enabled = YES;
	user2Button.enabled = YES;
	user3Button.enabled = YES;
}

-(IBAction)tweetSelected:(id)sender {
	[self disableTweetButtons];
	attempted += 1;
	if ([[sender tweetID] isEqualToString:correctTweetID]) {
		[self answerCorrect:sender];
	} else {
		[self answerWrong:sender];
	}
	[self setupRandomMode];
}

-(void)disableTweetButtons {
	tweet1Button.enabled = NO;
	tweet2Button.enabled = NO;
	tweet3Button.enabled = NO;
}

-(void)enableTweetButtons {
	tweet1Button.enabled = YES;
	tweet2Button.enabled = YES;
	tweet3Button.enabled = YES;
}

-(void)answerCorrect:(SRButton *)sender {
	scoreImage.image = [UIImage imageNamed:@"correct.png"];
	[self increaseScore];
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:sender,@"button",@"yes",@"correct",nil];
	[NSThread detachNewThreadSelector:@selector(saveFriendStat:) toTarget:self withObject:data];
}

-(void)answerWrong:(SRButton *)sender { 
	scoreImage.image = [UIImage imageNamed:@"wrong.png"];
	[self decreaseScore];
	NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:sender,@"button",@"no",@"correct",nil];
	[NSThread detachNewThreadSelector:@selector(saveFriendStat:) toTarget:self withObject:data];
}

-(void)increaseScore {
	score += 10;
	scoreLabel.text = [NSString stringWithFormat:@"%d",score];
	correctInARow += 1;
	if (correctInARow % 5 == 0 && [twittaddictAppDelegate gameCenter]) {
		[self inARowAchievement];
	}
}

-(void)decreaseScore {
	score -= 5;
	scoreLabel.text = [NSString stringWithFormat:@"%d",score];
	correctInARow = 0;
}

-(void)saveFriendStat:(NSDictionary *)data {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];	
	SRButton *button = [data objectForKey:@"button"];
	NSString *correct = [data objectForKey:@"correct"];
	twittaddictAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"FriendStat" inManagedObjectContext:context];
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDesc];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(userID = %@)", [button userID]];
	[request setPredicate:pred];
	NSError *error;
	NSArray *stats = [context executeFetchRequest:request error:&error];
	[request release];
	if ([stats count]>0) {
		NSDictionary *stat = [stats objectAtIndex:0];
		[stat setValue:[[stat valueForKey:@"attempts"]decimalNumberByAdding:[NSDecimalNumber one]] forKey:@"attempts"];
		if ([correct isEqualToString:@"yes"]) {
			[stat setValue:[[stat valueForKey:@"correct"]decimalNumberByAdding:[NSDecimalNumber one]] forKey:@"correct"];
		}
		[stat setValue:[self percentCorrect:[stat valueForKey:@"correct"] withAttempts:[stat valueForKey:@"attempts"]] forKey:@"percentCorrect"];
		if (![[stat valueForKey:@"screenName"] isEqualToString:[button screenName]]) {
			[stat setValue:[button screenName] forKey:@"screenName"];
		}
		if (![[stat valueForKey:@"profileImageURL"] isEqualToString:[button profileImageURL]]) {
			[stat setValue:[button profileImageURL] forKey:@"profileImageURL"];
		}
		NSError *error;
		[context save:&error];
	} else {
		NSManagedObject *statObject = [NSEntityDescription
										insertNewObjectForEntityForName:@"FriendStat" 
										inManagedObjectContext:context];
		[statObject setValue:[button userID] forKey:@"userID"];
		[statObject setValue:[NSDecimalNumber one] forKey:@"attempts"];
		if ([correct isEqualToString:@"yes"]) {
			[statObject setValue:[NSDecimalNumber one] forKey:@"correct"];
		} else {
			[statObject setValue:[NSDecimalNumber zero] forKey:@"correct"];
		}
		[statObject setValue:[self percentCorrect:[statObject valueForKey:@"correct"] withAttempts:[statObject valueForKey:@"attempts"]] forKey:@"percentCorrect"];
		[statObject setValue:[button screenName] forKey:@"screenName"];
		[statObject setValue:[button profileImageURL] forKey:@"profileImageURL"];
		NSError *error;
		[context save:&error];
	}
	[runLoop run];
	[pool release];
}



-(NSDecimalNumber *)percentCorrect:(NSDecimal *)correct withAttempts:(NSDecimal *)attempts {
	NSDecimalNumberHandler *roundingBehavior = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundUp scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
	return [[correct decimalNumberByDividingBy:attempts withBehavior:roundingBehavior] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"100"]];
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
	if ([twittaddictAppDelegate gameCenter]) {
		[self reportScore:score forCategory:@"twittaddict1"];
		if (![[twittaddictAppDelegate playerAchievements] containsObject:@"all_achievement"] && attempted==correctInARow) {
			[self awardAchievement:@"all_achievement"];
		}
	}
	scoreSaved = YES;
}

# pragma mark GameKit

- (void) reportScore:(int)newScore forCategory: (NSString*)category {
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];
	scoreReporter.value = newScore;
	[scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
		if (error != nil) {
			NSLog(@"report error %d",[error code]);
        }
    }];
}

- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent {
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
	if (achievement) {
		achievement.percentComplete = percent;
		[achievement reportAchievementWithCompletionHandler:^(NSError *error) {
			 if (error != nil) {
				 // Retain the achievement object and try again later (not shown)
			 }
		 }];
    }
}

-(void)inARowAchievement {
	switch (correctInARow) {
		case 5:
			[self awardAchievement:@"five_achievement"];
			break;
		case 10:
			[self awardAchievement:@"ten_achievement"];
			break;
		case 15:
			[self awardAchievement:@"fifteen_achievement"];
			break;
		case 20:
			[self awardAchievement:@"twenty_achievement"];
			break;
		case 25:
			[self awardAchievement:@"twentyfive_achievement"];
			break;
		case 30:
			[self awardAchievement:@"thirty_achievement"];
			break;
		default:
			break;
	}
}

-(void)awardAchievement:(NSString *)achievementID {
	if (![[twittaddictAppDelegate playerAchievements] containsObject:achievementID]) {
		[self reportAchievementIdentifier:achievementID percentComplete:100.0];
		[[twittaddictAppDelegate playerAchievements] addObject:achievementID];
		newAchievements = YES;
	}
}

# pragma mark memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.backupTweets = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[tweets release];
	[backupTweets release];
	[follows release];
	[currentUser release];
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
	[gameThread release];
	[background2Image release];
	[tweet1Button release];
	[tweet2Button release];
	[tweet3Button release];
	[userImage release];
	[userLabel release];
	[correctTweetID release];
	[mode1InstructionImage release];
	[mode2InstructionImage release];
    [super dealloc];
}

@end