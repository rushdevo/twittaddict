//
//  GameOverController.h
//  twittaddict
//
//  Created by Shannon Rush on 12/27/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"
#import "MatchController.h"
#import <GameKit/GameKit.h>

@interface GameOverController : BaseController <UITableViewDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate> {
	UILabel *scoreLabel;
	NSDictionary *lastScore;
	NSArray *highScores;
	UITableView *highScoreTable;
	MatchController *matchView;
	IBOutlet UIButton *leaderboardButton;
	IBOutlet UIButton *newAchievementButton;
	IBOutlet UIButton *achievementButton;
}

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) NSDictionary *lastScore;
@property (nonatomic, retain) NSArray *highScores;
@property (nonatomic, retain) IBOutlet UITableView *highScoreTable;
@property (nonatomic, retain) MatchController *matchView;

-(IBAction)playAgain;
-(NSDictionary *)lastScore;
-(NSArray *)highScores;
-(IBAction)showStats;
-(IBAction)showLeaderboard;
-(IBAction)showAchievements;

@end
