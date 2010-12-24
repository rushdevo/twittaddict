//
//  MatchController.h
//  twittaddict
//
//  Created by Shannon Rush on 12/19/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"  
#import "MGTwitterEngine.h"
//#import "BaseController.h"

@class SA_OAuthTwitterEngine; 

@interface MatchController : UIViewController <SA_OAuthTwitterControllerDelegate> {
	SA_OAuthTwitterEngine    *_engine; 
	MGTwitterEngine *twitterEngine;
	
	NSMutableArray *tweets;
	NSMutableArray *follows;
	NSMutableArray *friendIDs;
	NSString *username;
	BOOL retrievedUsername;
	
	UILabel *scoreLabel;
	
	// match mode 1
	UIButton *user1Button;
	UIButton *user2Button;
	UIButton *user3Button;
	UILabel *user1Label;
	UILabel *user2Label;
	UILabel *user3Label;
	UILabel *tweetLabel;
	NSString *correctUserID;
	NSMutableArray *selectedUsers;
	
}

@property(nonatomic,retain) NSMutableArray *tweets;
@property(nonatomic,retain) NSMutableArray *follows;
@property(nonatomic,retain) NSMutableArray *friendIDs;
@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *correctUserID;
@property(nonatomic,retain) NSMutableArray *selectedUsers;
@property(nonatomic,retain) IBOutlet UIButton *user1Button;
@property(nonatomic,retain) IBOutlet UIButton *user2Button;
@property(nonatomic,retain) IBOutlet UIButton *user3Button;
@property(nonatomic,retain) IBOutlet UILabel *user1Label;
@property(nonatomic,retain) IBOutlet UILabel *user2Label;
@property(nonatomic,retain) IBOutlet UILabel *user3Label;
@property(nonatomic,retain) IBOutlet UILabel *scoreLabel;
@property(nonatomic,retain) IBOutlet UILabel *tweetLabel;

-(void)setupMode1;
-(void)setupMode2;

@end
