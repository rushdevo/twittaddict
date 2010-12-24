    //
//  BaseController.m
//  twittaddict
//
//  Created by Shannon Rush on 12/23/10.
//  Copyright 2010 Rush Devo. All rights reserved.
//

#import "BaseController.h"


@implementation BaseController

- (void)viewDidLoad {
	responseData = [[NSMutableData data] retain];
    [super viewDidLoad];
}

-(NSURL *) constructURL:(NSString *)path {
	NSString *urlString=[NSString stringWithFormat:@"%@%@",@"http://api.twitter.com/1/", path];
	return [NSURL URLWithString:urlString];
}

-(void) noConnectionAlert {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Connect" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}


-(void) errorAlert:(NSArray *)errors {
	NSString *alertErrors = [errors componentsJoinedByString:@"\n"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable To Save" message:alertErrors delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

-(void) asynchRequest:(NSString *)path withMethod:(NSString *)method withContentType:(NSString *)contentType withData:(NSString *)dataString {
	NSURL *url = [self constructURL:path]; 
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	
	if (dataString != nil && [dataString length] > 0) {
		[request setHTTPBody:[dataString dataUsingEncoding:NSISOLatin1StringEncoding]];
	}
    [request setHTTPMethod:method];
	[request setValue:contentType forHTTPHeaderField:@"content-type"];
    [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
}

-(void) handleAsynchResponse:(NSDictionary *)data {
	//Override in subclasses unless your response is a no-op for some reason
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self noConnectionAlert];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	NSDictionary *data = [[NSDictionary alloc] init];
	data = [responseString JSONValue];
	NSLog(@"%@", data);
	[responseString release];
	[self handleAsynchResponse:data];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end


@implementation NSString (Escaping)
- (NSString*)stringWithPercentEscape {            
    return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8) autorelease];
}
@end
