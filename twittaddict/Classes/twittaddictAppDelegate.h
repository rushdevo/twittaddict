//
//  TwitterRushAppDelegate.h
//  TwitterRush


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class MatchController;

BOOL gameCenter;

@interface twittaddictAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MatchController *viewController;
	
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MatchController *viewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(BOOL)gameCenter;
+(void)setGameCenter:(BOOL)hasGameCenter;
-(NSURL *)applicationDocumentsDirectory;
-(void)saveContext;
-(BOOL)isGameCenterAvailable;
-(void)loadGame;
-(void)authenticatePlayer;
-(void)checkLocalPlayer;


@end



