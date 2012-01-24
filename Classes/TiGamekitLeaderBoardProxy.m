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


-(void)showLeaderBoard:(id)arg
{
    ENSURE_SINGLE_ARG(arg, NSString);
	ENSURE_UI_THREAD(showLeaderBoard,arg);
	
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) 
	{
		self.currentLeaderBoard = arg;
				
		leaderboardController.category = arg;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self;
		[[TiApp app] showModalController:leaderboardController animated:YES];
	}
}

- (void) reloadHighScoresForCategory
{
	GKLeaderboard* leaderBoard= [[[GKLeaderboard alloc] init] autorelease];
	leaderBoard.category = self.currentLeaderBoard;
	leaderBoard.timeScope = GKLeaderboardTimeScopeAllTime;
	leaderBoard.range = NSMakeRange(1, 1);
	
	[leaderBoard loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error)
	 {
         [self fireEvent:@"scoreSubmitted"];
	 }]; 
}

- (void) reportScore:(id)args 
{
    NSString* category;
    NSNumber* score;
    
    ENSURE_ARG_AT_INDEX(category, args, 0, NSString);
    ENSURE_ARG_AT_INDEX(score, args, 1, NSNumber);
    
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];	
	scoreReporter.value = [TiUtils intValue:score];
	[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error) 
	 {
         if (error == nil) {
             [self reloadHighScoresForCategory];
             NSLog(@"[INFO] Score Reported!");
         }
         else {
             NSLog(@"[ERROR] Score not reported due to an error: %@", error);
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