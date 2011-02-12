//
//  TwitterRushAppDelegate.m
//  TwitterRush


#import "twittaddictAppDelegate.h"
#import "MatchController.h"
#import <GameKit/GameKit.h>

@implementation twittaddictAppDelegate

@synthesize window;
@synthesize viewController;

#pragma mark accessors

+(BOOL)gameCenter {
	return gameCenter;
}

+(void)setGameCenter:(BOOL)hasGameCenter {
	gameCenter = hasGameCenter;
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	authenticating = NO;
	gameStarted = NO;
	userCanceled = NO;
	[self checkLocalPlayer];
	return YES;
}

-(void)checkLocalPlayer {
	if ([self isGameCenterAvailable]) {
		if (![[GKLocalPlayer localPlayer]isAuthenticated]) {
			[self registerForAuthenticationNotification];
			[self authenticatePlayer];
		} else {
			NSLog(@"game started from player authenticated");
			[self loadGame]; // player is authenticated
		}
	} else {
		gameCenter = NO;
		NSLog(@"game started from no game center");
		[self loadGame];
	}
}


-(void)authenticatePlayer {
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
		if (error != nil) {
			if ([error code]==2) { // user canceled game center
				gameCenter = NO;
				userCanceled = YES;
				NSLog(@"game started from auth player");
				[self loadGame];
			} 
		} 
	}];
}

- (void) registerForAuthenticationNotification {	
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver: self
		selector:@selector(authenticationChanged)
		name:GKPlayerAuthenticationDidChangeNotificationName
	    object:nil];
}

- (void) authenticationChanged {
	NSLog(@"AUTH CHANGED");
	if ([[GKLocalPlayer localPlayer]isAuthenticated] && !gameStarted && !authenticating) {
		gameCenter = YES;
		NSLog(@"game started from auth changed");
		[self loadGame];
	}
}

-(void)loadGame {
	gameStarted = YES;
	viewController = [[MatchController alloc] initWithNibName:@"MatchController" bundle:[NSBundle mainBundle]];
	[viewController.view setFrame:[[UIScreen mainScreen]applicationFrame]];
	[window addSubview:viewController.view];
	[window makeKeyAndVisible];
}

#pragma mark game center

-(BOOL)isGameCenterAvailable {
	// Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	// The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	return (gcClass && osVersionSupported);
}


#pragma mark -


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"applicationWillEnterForeground");
	if (!userCanceled) {
		gameStarted = NO;
		authenticating = YES;
		[self checkLocalPlayer];
	} else {
		[self loadGame];
	}
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


- (void)saveContext {
    
    NSError *error = nil;
	NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        } 
    }
}    


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    
    if (managedObjectContext_ != nil) {
        return managedObjectContext_;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext_ = [[NSManagedObjectContext alloc] init];
        [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext_;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel_ != nil) {
        return managedObjectModel_;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"twittaddict" withExtension:@"momd"];
    managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel_;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator_ != nil) {
        return persistentStoreCoordinator_;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"twittaddict.sqlite"];
    
    NSError *error = nil;
    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator_;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    
    [managedObjectContext_ release];
    [managedObjectModel_ release];
    [persistentStoreCoordinator_ release];
    
    [window release];
    [super dealloc];
}

@end
