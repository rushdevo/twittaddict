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
#import "BaseController.h"

@class SA_OAuthTwitterEngine; 

@interface MatchController : BaseController <SA_OAuthTwitterControllerDelegate> {
	SA_OAuthTwitterEngine *_engine; 
	MGTwitterEngine *twitterEngine;
	
	IBOutlet UIButton *playButton;
	IBOutlet UIImageView *scoreImage;
	BOOL newAchievements;
	NSMutableArray *tweets;
	NSMutableArray *backupTweets;
	NSMutableArray *follows;
	NSDictionary *currentUser;
	BOOL retrievedCurrentUser;
	int score;
	int correctInARow;
	int attempted;
	int secondsRemaining;
	UILabel *scoreLabel;
	UILabel *timerLabel;
	UIActivityIndicatorView *loadingActivity;
	UIImageView *loadingImage;
	BOOL scoreSaved;
	int instructMode1;
	int instructMode2;
	NSMutableArray *queue;
	
	NSThread *gameThread;
	
	// match mode 1
	UIImageView *mode1InstructionImage;
	UIImageView *background1Image;
	SRButton *user1Button;
	SRButton *user2Button;
	SRButton *user3Button;
	IBOutlet UIImageView *user1Image;
	IBOutlet UIImageView *user2Image;
	IBOutlet UIImageView *user3Image;
	UILabel *user1Label;
	UILabel *user2Label;
	UILabel *user3Label;
	UITextView *tweetText;
	NSMutableString *correctUserID;
	NSMutableArray *selectedUsers;
	
	//match mode 2
	UIImageView *mode2InstructionImage;
	UIImageView *background2Image;
	SRButton *tweet1Button;
	SRButton *tweet2Button;
	SRButton *tweet3Button;
	UIImageView *userImage;
	UILabel *userLabel;
	NSMutableString *correctTweetID;
}

@property(nonatomic,retain) NSMutableArray *queue;
@property BOOL newAchievements;
@property(nonatomic,retain) NSMutableArray *tweets;
@property(nonatomic,retain) NSMutableArray *backupTweets;
@property(nonatomic,retain) NSMutableArray *follows;
@property(nonatomic,retain) NSDictionary *currentUser;
@property(nonatomic,retain) NSMutableString *correctUserID;
@property(nonatomic,retain) NSMutableArray *selectedUsers;
@property(nonatomic,retain) IBOutlet UIImageView *background1Image;
@property(nonatomic,retain) IBOutlet SRButton *user1Button;
@property(nonatomic,retain) IBOutlet SRButton *user2Button;
@property(nonatomic,retain) IBOutlet SRButton *user3Button;
@property(nonatomic,retain) IBOutlet UILabel *user1Label;
@property(nonatomic,retain) IBOutlet UILabel *user2Label;
@property(nonatomic,retain) IBOutlet UILabel *user3Label;
@property(nonatomic,retain) IBOutlet UILabel *scoreLabel;
@property(nonatomic,retain) IBOutlet UILabel *timerLabel;
@property(nonatomic,retain) IBOutlet UITextView *tweetText;
@property(nonatomic,retain) IBOutlet UIActivityIndicatorView *loadingActivity;
@property(nonatomic,retain) IBOutlet UIImageView *loadingImage;
@property(nonatomic,retain) NSThread *gameThread;
@property(nonatomic,retain) IBOutlet UIImageView *mode1InstructionImage;
@property(nonatomic,retain) IBOutlet UIImageView *mode2InstructionImage;
@property(nonatomic,retain) IBOutlet UIImageView *background2Image;
@property(nonatomic,retain) IBOutlet SRButton *tweet1Button;
@property(nonatomic,retain) IBOutlet SRButton *tweet2Button;
@property(nonatomic,retain) IBOutlet SRButton *tweet3Button;
@property(nonatomic,retain) IBOutlet UIImageView *userImage;
@property(nonatomic,retain) IBOutlet UILabel *userLabel;
@property(nonatomic,retain) NSMutableString *correctTweetID;

-(void)loadQueue;
-(BOOL)userInFriends:(NSString *)userID;
-(void)addUserToFriends:(NSDictionary *)user;
-(NSDictionary *)getUserFromFriends:(NSDictionary *)user;
-(void)hideLoading;
-(void)setupRandomMode;
-(void)hideMode1Components;
-(void)showMode1Components;
-(void)hideMode2Components;
-(void)showMode2Components;
-(void)setupMode1;
-(void)initMode1Components:(NSDictionary *)element;
-(void)initUser:(NSDictionary *)user withButton:(SRButton *)button withImage:(UIImageView *)imageView withLabel:(UILabel *)label;
-(void)setupMode2;
-(void)initMode2Components:(NSMutableArray *)tweetChoices withElement:(NSDictionary *)element;
-(void)initTweet:(NSDictionary *)tweet withButton:(SRButton *)button;
-(void)initButton:(SRButton *)button withUser:(NSDictionary *)user;
-(IBAction)userSelected:(id)sender;
-(IBAction)tweetSelected:(id)sender;
-(void)increaseScore;
-(void)decreaseScore;
-(IBAction)startGame;
-(void)startTimer;
-(void)startTimerThread;
-(void)countdown:(NSTimer *)timer;
-(void)presentGameOver;
-(void)saveScore;
-(void)reportScore:(int)newScore forCategory:(NSString*) category;
-(NSDecimalNumber *)percentCorrect:(NSDecimal *)correct withAttempts:(NSDecimal *)attempts;
-(void)saveFriendStat:(NSDictionary *)data;
-(void)disableUserButtons;
-(void)enableUserButtons;
-(void)disableTweetButtons;
-(void)enableTweetButtons;
-(void)increaseInstructionView:(NSString *)mode;
-(NSMutableArray *)userChoices:(NSDictionary *)correctUser;
-(NSMutableArray *)tweetChoices:(NSDictionary *)element;
-(NSDictionary *)randomTweet;
-(void)loadAchievements;
-(void)inARowAchievement;
- (void)reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;
-(void)awardAchievement:(NSString *)achievementID;
-(void)answerCorrect:(SRButton *)sender;
-(void)answerWrong:(SRButton *)sender;
-(void)initFriends:(NSArray *)userInfo;


@end
