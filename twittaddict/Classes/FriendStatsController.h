//
//  FriendStatsController.h
//  twittaddict
//
//  Created by Shannon Rush on 1/6/11.
//  Copyright 2011 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface FriendStatsController : BaseController {
	NSDictionary *currentUser;
	NSMutableArray *bestStats;
	UILabel *statsLabel;
	UITableView *statsTable;
}

@property(nonatomic,retain) NSDictionary *currentUser;
@property(nonatomic,retain) NSMutableArray *bestStats;
@property(nonatomic,retain) IBOutlet UILabel *statsLabel;
@property(nonatomic,retain) IBOutlet UITableView *statsTable;

@end
