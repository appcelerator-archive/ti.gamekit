/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiGamekitModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation TiGamekitModule

@synthesize leaderBoardProxy;
@synthesize currentPlayerID, 
gameCenterAuthenticationComplete;

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"634adffb-5b75-45a8-ab28-a835219adbf4";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.gamekit";
}

#pragma mark Lifecycle

-(void)startup
{
	[super startup];
	[self isPlayerAuthenticated ];
}

#pragma mark Cleanup 

-(void)dealloc
{
	[leaderBoardProxy release];
	
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Listener Notifications

-(id)isAvailable:(id)args
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return NUMBOOL(gcClass && osVersionSupported); 
}

- (BOOL)isPlayerAuthenticated
{
	self.gameCenterAuthenticationComplete = NO;
    
    /*if (!isGameCenterAPIAvailable()) {
        // Game Center is not available. 
        self.gameCenterAuthenticationComplete = NO;
    } else { */
        
        GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
        
        /*
         The authenticateWithCompletionHandler method is like all completion handler methods and runs a block
         of code after completing its task. The difference with this method is that it does not release the 
         completion handler after calling it. Whenever your application returns to the foreground after 
         running in the background, Game Kit re-authenticates the user and calls the retained completion 
         handler. This means the authenticateWithCompletionHandler: method only needs to be called once each 
         time your application is launched. This is the reason the sample authenticates in the application 
         delegate's application:didFinishLaunchingWithOptions: method instead of in the view controller's 
         viewDidLoad method.
         
         Remember this call returns immediately, before the user is authenticated. This is because it uses 
         Grand Central Dispatch to call the block asynchronously once authentication completes.
         */
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            // If there is an error, do not assume local player is not authenticated. 
            if (localPlayer.isAuthenticated) {
                
                // Enable Game Center Functionality 
                self.gameCenterAuthenticationComplete = YES;
				
                if (! self.currentPlayerID || ! [self.currentPlayerID isEqualToString:localPlayer.playerID]) {
					
                    // Current playerID has changed. Create/Load a game state around the new user. 
                    self.currentPlayerID = localPlayer.playerID;
                    
                    // Load game instance for new current player, if none exists create a new.
					[self fireEvent:@"loggedIn"];
                }
            } else {     
                // No user is logged into Game Center, run without Game Center support or user interface. 
                self.gameCenterAuthenticationComplete = NO;
                
                [self fireEvent:@"notLoggedIn"];
            }
        }];
    //}    
    
    // The user is not authenticated until the Completion Handler block is called. 
    return YES;
}

@end
