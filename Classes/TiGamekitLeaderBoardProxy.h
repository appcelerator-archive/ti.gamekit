/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <GameKit/GameKit.h>

#define kAllBoards @"appcgkall"

@class GKLeaderboard, GKAchievement, GKPlayer,GKScore;


@interface TiGamekitLeaderBoardProxy : TiProxy<GKLeaderboardViewControllerDelegate> {
	NSString* currentLeaderBoard;
}

@property (nonatomic,retain) NSString *currentLeaderBoard;

-(void)showLeaderBoard:(id)args;

@end