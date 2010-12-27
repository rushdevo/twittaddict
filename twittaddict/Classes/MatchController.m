//
//  MatchController.m
//  twittaddict
//
//  Created by Shannon Rush on 12/19/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import "MatchController.h"
#import "SA_OAuthTwitterEngine.h" 

#define kOAuthConsumerKey @"fzhClftPYrGwJGpo86xeGw"         //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret @"Np92rlHsIy4IV4FO7ELPw6IwM16QzTNAUeZkdrrsOUA"     //REPLACE With Twitter App OAuth Secret  

@implementation MatchController

@synthesize tweets;
@synthesize follows;
@synthesize username;
@synthesize friendIDs;
@synthesize scoreLabel;
@synthesize user1Button;
@synthesize user2Button;
@synthesize user3Button;
@synthesize user1Label;
@synthesize user2Label;
@synthesize user3Label;
@synthesize tweetText;
@synthesize selectedUsers;
@synthesize correctUserID;


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
	tweets = [[NSMutableArray alloc]init];
	follows = [[NSMutableArray alloc]init];
	friendIDs = [[NSMutableArray alloc]init];
	retrievedUsername = NO;
	correctUserID = [[NSString alloc]init];
	selectedUsers = [[NSMutableArray alloc]init];	
	[_engine getFollowedTimelineSinceID:0 startingAtPage:0 count:200];
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
		NSMutableDictionary *tweet = [[NSMutableDictionary alloc]init];
		[tweet setObject:[status objectForKey:@"id"] forKey:@"tweet_id"];
		[tweet setObject:[status objectForKey:@"text"] forKey:@"text"];
		[tweet setObject:[[status objectForKey:@"user"]objectForKey:@"id"] forKey:@"user_id"];
		[tweets addObject:tweet];
		[tweet release];
	}
	NSLog(@"TWEETS: %d",[tweets count]);
	if ([tweets count] > 0 && [friendIDs count]>0) {
		[self setupMode1];
	}
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier {
	if (!retrievedUsername) {
		username = [[userInfo objectAtIndex:0]objectForKey:@"screen_name"];
		retrievedUsername = YES;
		[_engine getFriendIDsFor:username];
	} else {
		[self initMode1Components:userInfo];
	}
}

- (void)socialGraphInfoReceived:(NSArray *)socialGraphInfo forRequest:(NSString *)connectionIdentifier {
	[friendIDs setArray:[[socialGraphInfo objectAtIndex:0]objectForKey:@"ids"]];
	if ([tweets count] > 0 && [friendIDs count]>0) {
		[self setupMode1];
	}
}

#pragma mark Game Setup


-(void)setupMode1 {
	if ([tweets count]==0) {
		[_engine getFollowedTimelineSinceID:0 startingAtPage:0 count:200];
	} else{
		NSDictionary *tweet = [NSDictionary dictionaryWithDictionary:[tweets objectAtIndex:arc4random()%[tweets count]]];
		tweetText.text = [tweet valueForKey:@"text"];
		correctUserID = [[NSString alloc]initWithString:[tweet valueForKey:@"user_id"]];
		[tweets removeObject:tweet];
		
		NSString *userID1 = [self getUserIDNotEqualTo:[NSArray arrayWithObject:correctUserID]];
		NSString *userID2 = [self getUserIDNotEqualTo:[NSArray arrayWithObjects:correctUserID,userID1,nil]];
		NSString *friendString = [NSString stringWithFormat:@"%@, %@, %@", correctUserID, userID1, userID2];
		[_engine getBulkUserInformationFor:friendString];
	}
}

-(NSString *)getUserIDNotEqualTo:(NSArray *)userIDs {
	NSString *tempID = [self tempUserID];
	if (![userIDs containsObject:tempID]) {
		return tempID;
	} else {
		[self getUserIDNotEqualTo:userIDs];
	}
}

-(NSString *)tempUserID {
	return [friendIDs objectAtIndex:arc4random()%[friendIDs count]];
}				

-(void)initMode1Components:(NSArray *)userInfo {
	[self initUser:[userInfo objectAtIndex:0] withButton:user1Button withLabel:user1Label];
	[self initUser:[userInfo objectAtIndex:1] withButton:user2Button withLabel:user2Label];
	[self initUser:[userInfo objectAtIndex:2] withButton:user3Button withLabel:user3Label];
}

-(void)initUser:(NSDictionary *)user withButton:(SRButton *)button withLabel:(UILabel *)label {
	UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]]];
	[button setImage:image forState:UIControlStateNormal];
	button.userID = [user objectForKey:@"id"];
	label.text = [user objectForKey:@"screen_name"];
}

-(IBAction)userSelected:(id)sender {
	if ([[sender userID] isEqualToString:correctUserID]) {
		[sender setImage:[UIImage imageNamed:@"correct.png"] forState:UIControlStateNormal];
		score += 10;
		scoreLabel.text = [NSString stringWithFormat:@"%d",score];
	} else {
		[sender setImage:[UIImage imageNamed:@"wrong.png"] forState:UIControlStateNormal];
	}
	[self setupMode1];
}

-(void)setupMode2 {
	
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
	[tweets release];
	[follows release];
	[username release];
	[friendIDs release];
	[_engine release];
	[selectedUsers release];
	[scoreLabel release];
	[user1Button release];
	[user2Button release];
	[user3Button release];
	[user1Label release];
	[user2Label release];
	[user3Label release];
	[tweetText release];
	[correctUserID release];
    [super dealloc];
}


@end