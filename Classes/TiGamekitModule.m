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

BOOL isGameCenterAPIAvailable()
{
    // Check for presence of GKLocalPlayer API.
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // The device must be running running iOS 4.1 or later.
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported); 
}

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
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	[self isPlayerAuthenticated ];
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	[leaderBoardProxy release];
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added 
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
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
					[self fireEvent:@"loggedin"];
                }
            } else {     
                // No user is logged into Game Center, run without Game Center support or user interface. 
                self.gameCenterAuthenticationComplete = NO;
            }
        }];
    //}    
    
    // The user is not authenticated until the Completion Handler block is called. 
    return YES;
}

#pragma Public APIs

- (void) achievementSubmitted: (GKAchievement*) ach error:(NSError*) error;
{
	if((error == NULL) && (ach != NULL))
	{
		if(ach.percentComplete == 100.0)
		{
			/*[self showAlertWithTitle: @"Achievement Earned!"
							 message: [NSString stringWithFormat: @"Great job!  You earned an achievement: \"%@\"", NSLocalizedString(ach.identifier, NULL)]];*/
			[self fireEvent:@"achievementEarned"];
		}
		else
		{
			if(ach.percentComplete > 0)
			{
				/*[self showAlertWithTitle: @"Achievement Progress!"
								 message: [NSString stringWithFormat: @"Great job!  You're %.0f\%% of the way to: \"%@\"",ach.percentComplete, NSLocalizedString(ach.identifier, NULL)]];*/
				[self fireEvent:@"achievementProgress"];
			}
		}
	}
	else
	{
		/*[self showAlertWithTitle: @"Achievement Submission Failed!"
						 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];*/
		[self fireEvent:@"achievementFailed"];
	}
}


-(id)example:(id)args
{
	// example method
	return @"hello world";
}

-(id)exampleProp
{
	// example property getter
	return @"hello world";
}

-(void)exampleProp:(id)value
{
	// example property setter
}

@end
