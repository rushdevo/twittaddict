//
//  statCell.h
//  twittaddict
//
//  Created by Shannon Rush on 1/8/11.
//  Copyright 2011 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface statCell : UITableViewCell {
	UIImageView *profileImage;
	UILabel *nameLabel;
	UILabel *percentLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *profileImage;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *percentLabel;

@end
