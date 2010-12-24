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
@synthesize tweetLabel;
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
			NSLog(@"here");
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
	// select random tweet
	NSDictionary *tweet = [tweets objectAtIndex:random()%[tweets count]];
	tweetLabel.text = [tweet valueForKey:@"text"];
	correctUserID = [tweet valueForKey:@"user_id"];
	[tweets removeObject:tweet];
	
	// get user information for correct user and 2 other random users

	[friendIDs removeObject:correctUserID];
	NSString *userID1 = [friendIDs objectAtIndex:random()%[friendIDs count]];
	[friendIDs removeObject:userID1];
	NSString *userID2 = [friendIDs objectAtIndex:random()%[friendIDs count]];
	[friendIDs removeObject:userID2];
	NSString *friendString = [NSString stringWithFormat:@"%@, %@, %@", correctUserID, userID1, userID2];
	[_engine getBulkUserInformationFor:friendString];
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
	[tweetLabel release];
	[correctUserID release];
    [super dealloc];
}


@end