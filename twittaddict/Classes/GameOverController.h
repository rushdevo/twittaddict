//
//  GameOverController.h
//  twittaddict
//
//  Created by Shannon Rush on 12/27/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseController.h"

@interface GameOverController : BaseController {
	UILabel *scoreLabel;
	UITextView *messageText;
	NSDictionary *lastScore;
}

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UITextView *messageText;
@property (nonatomic, retain) NSDictionary *lastScore;

-(IBAction)playAgain;
-(NSDictionary *)lastScore;

@end
