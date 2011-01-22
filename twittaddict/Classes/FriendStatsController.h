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
	UILabel *statsLabel;
	UIImageView *bffImage;
	UILabel *bffLabel;
}

@property(nonatomic,retain) NSDictionary *currentUser;
@property(nonatomic,retain) IBOutlet UILabel *statsLabel;
@property(nonatomic,retain) IBOutlet UIImageView *bffImage;
@property(nonatomic,retain) IBOutlet UILabel *bffLabel;

-(void)loadBFF;

@end
