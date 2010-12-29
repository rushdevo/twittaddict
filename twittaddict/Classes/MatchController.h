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
#import "SRButton.h"

@class SA_OAuthTwitterEngine; 

@interface MatchController : UIViewController <SA_OAuthTwitterControllerDelegate> {
	SA_OAuthTwitterEngine    *_engine; 
	MGTwitterEngine *twitterEngine;
	
	NSMutableArray *tweets;
	NSMutableArray *follows;
	NSMutableArray *friendIDs;
	NSString *authID;
	BOOL retrievedAuthID;
	int score;
	int secondsRemaining;
	UILabel *scoreLabel;
	UILabel *timerLabel;
	
	// match mode 1
	SRButton *user1Button;
	SRButton *user2Button;
	SRButton *user3Button;
	UILabel *user1Label;
	UILabel *user2Label;
	UILabel *user3Label;
	UITextView *tweetText;
	NSString *correctUserID;
	NSMutableArray *selectedUsers;
}

@property(nonatomic,retain) NSMutableArray *tweets;
@property(nonatomic,retain) NSMutableArray *follows;
@property(nonatomic,retain) NSMutableArray *friendIDs;
@property(nonatomic,retain) NSString *authID;
@property(nonatomic,retain) NSString *correctUserID;
@property(nonatomic,retain) NSMutableArray *selectedUsers;
@property(nonatomic,retain) IBOutlet SRButton *user1Button;
@property(nonatomic,retain) IBOutlet SRButton *user2Button;
@property(nonatomic,retain) IBOutlet SRButton *user3Button;
@property(nonatomic,retain) IBOutlet UILabel *user1Label;
@property(nonatomic,retain) IBOutlet UILabel *user2Label;
@property(nonatomic,retain) IBOutlet UILabel *user3Label;
@property(nonatomic,retain) IBOutlet UILabel *scoreLabel;
@property(nonatomic,retain) IBOutlet UILabel *timerLabel;
@property(nonatomic,retain) IBOutlet UITextView *tweetText;

-(void)setupMode1;
-(void)initMode1Components:(NSArray *)userInfo;
-(void)initUser:(NSDictionary *)user withButton:(SRButton *)button withLabel:(UILabel *)label;
-(NSString *)getUserIDNotEqualTo:(NSArray *)userIDs;
-(NSString *)tempUserID;
-(void)setupMode2;
-(IBAction)userSelected:(id)sender;
-(void)countdown;
-(void)saveScore;

@end
