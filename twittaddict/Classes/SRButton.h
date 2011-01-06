//
//  SRButton.h
//  twittaddict
//
//  Created by Shannon Rush on 12/26/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SRButton : UIButton {
	NSString *userID;
	NSString *tweetID;
}

@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *tweetID;

@end
