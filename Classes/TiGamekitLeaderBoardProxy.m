/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiGamekitLeaderBoardProxy.h"
#import "TiApp.h"
#import "TiBase.h"
#import "TiUtils.h"

@implementation TiGamekitLeaderBoardProxy

@synthesize currentLeaderBoard;

- (id) init
{
	self = [super init];
	if(self!= NULL)
	{
		//earnedAchievementCache= NULL;
	}
	return self;
}


-(void)showLeaderBoard:(id)args
{
	ENSURE_UI_THREAD(showLeaderBoard,args);
	
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) 
	{
		self.currentLeaderBoard = [args objectAtIndex:0];
				
		leaderboardController.category = [args objectAtIndex:0];
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self;
		[[TiApp app] showModalController:leaderboardController animated:YES];
	}
	
}

- (void) reloadHighScoresForCategory
{
	GKLeaderboard* leaderBoard= [[[GKLeaderboard alloc] init] autorelease];
	leaderBoard.category= self.currentLeaderBoard;
	leaderBoard.timeScope= GKLeaderboardTimeScopeAllTime;
	leaderBoard.range= NSMakeRange(1, 1);
	
	[leaderBoard loadScoresWithCompletionHandler:  ^(NSArray *scores, NSError *error)
	 {
         [self fireEvent:@"scoreSubmitted"];
	 }]; 
}

- (void) reportScore:(id)args 
{
	//****** REMEBER TO ADD CHECKS FOR SCORE DATA TYPE!!! ****///
	//NSLog([TiUtils stringValue:[args objectAtIndex:0]]);
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:[TiUtils stringValue:[args objectAtIndex:1]]] autorelease];	
	scoreReporter.value = [TiUtils intValue:[args objectAtIndex:0]];
	[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error) 
	 {
         if (error == nil) {
             [self reloadHighScoresForCategory];
         }
         else {
             [self fireEvent:@"error" withObject:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
         }
	 }];
}


-(void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)leaderboardController
{
	[[[TiApp app] controller] dismissModalViewControllerAnimated: YES];
	[leaderboardController release];
}

@end