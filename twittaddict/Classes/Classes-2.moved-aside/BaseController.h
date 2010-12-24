//
//  BaseController.h
//  twittaddict
//
//  Created by Shannon Rush on 12/19/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BaseController : UIViewController {
	NSMutableData *responseData;
}

-(void) noConnectionAlert;
-(void) errorAlert:(NSArray *)errors;
-(NSURL *) constructURL:(NSString *)path;
-(void) asynchRequest:(NSString *)path withMethod:(NSString *)method withContentType:(NSString *)contentType withData:(NSString *)data;
-(void) handleAsynchResponse:(NSDictionary *)data;

@end
