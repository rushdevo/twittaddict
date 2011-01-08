//
//  statCell.m
//  twittaddict
//
//  Created by Shannon Rush on 1/8/11.
//  Copyright 2011 Rush Devo. All rights reserved.
//

#import "statCell.h"

@implementation statCell

@synthesize profileImage;
@synthesize nameLabel;
@synthesize percentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
	[profileImage release];
	[nameLabel release];
	[percentLabel release];
    [super dealloc];
}


@end
