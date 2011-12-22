/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiGamekitAchievementsProxy.h"

#import "TiUtils.h"
#import "TiApp.h"

@implementation TiGamekitAchievementsProxy

@synthesize earnedAchievementCache;

- (id) init
{
	self = [super init];
	if(self!= NULL)
	{
		earnedAchievementCache = NULL;
	}
	return self;
}

- (void) showAchievements:(id)args
{
	ENSURE_UI_THREAD(showAchievements,args);
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL)
	{
		achievements.achievementDelegate = self;
		[[TiApp app] showModalController: achievements animated: YES];
	}
}

- (void) submitAchievement:(id)args //(NSString*) identifier percentComplete: (double) percentComplete
{
	//GameCenter check for duplicate achievements when the achievement is submitted, but if you only want to report 
	// new achievements to the user, then you need to check if it's been earned 
	// before you submit.  Otherwise you'll end up with a race condition between loadAchievementsWithCompletionHandler
	// and reportAchievementWithCompletionHandler.  To avoid this, we fetch the current achievement list once,
	// then cache it and keep it updated with any new achievements.
	if(self.earnedAchievementCache == NULL)
	{
		[GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *scores, NSError *error)
		 {
			 if(error == NULL)
			 {
				 NSMutableDictionary* tempCache= [NSMutableDictionary dictionaryWithCapacity: [scores count]];
				 for (GKAchievement* score in scores)
				 {
					 [tempCache setObject: score forKey: score.identifier];
				 }
				 self.earnedAchievementCache= tempCache;
				 //NSMutableDictionary* dict
				 [self submitAchievement: args];
			 }
			 else
			 {
				 //Something broke loading the achievement list.  Error out, and we'll try again the next time achievements submit.
                 [self fireEvent:@"error" withObject:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
			 }
			 
		 }];
	}
	else
	{
		//Search the list for the ID we're using...
		GKAchievement* achievement= [self.earnedAchievementCache objectForKey: [TiUtils stringValue:[args objectAtIndex:0]]];
		if(achievement != NULL)
		{
			if((achievement.percentComplete >= 100.0) || (achievement.percentComplete >= [TiUtils doubleValue:[args objectAtIndex:1]]))
			{
				//Achievement has already been earned so we're done.
				achievement= NULL;
			}
			achievement.percentComplete= [TiUtils doubleValue:[args objectAtIndex:1]];
		}
		else
		{
			achievement= [[[GKAchievement alloc] initWithIdentifier: [TiUtils stringValue:[args objectAtIndex:0]]] autorelease];
			achievement.percentComplete= [TiUtils doubleValue:[args objectAtIndex:1]];
			//Add achievement to achievement cache...
			[self.earnedAchievementCache setObject: achievement forKey: achievement.identifier];
		}
		if(achievement!= NULL)
		{
			//Submit the Achievement...
			[achievement reportAchievementWithCompletionHandler: ^(NSError *error)
			 {
                 if (error == NULL) {
                     [self fireEvent:(achievement.percentComplete < 100 ? @"progress" : @"earned")
                          withObject:[NSDictionary dictionaryWithObject:achievement.identifier forKey:@"identifier"]];
                 }
                 else {
                     [self fireEvent:@"error" withObject:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
                 }
			 }];
		}
	}
}

- (void) resetAchievements:(id)args
{
	self.earnedAchievementCache= NULL;
	[GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error) 
	 {
         if (error == NULL) {
             [self fireEvent:@"reset"];
         }
         else {
             [self fireEvent:@"error" withObject:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
         }
	 }];
}


- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)achievements;
{
	[[[TiApp app] controller] dismissModalViewControllerAnimated: YES];
	[achievements release];
}

@end
