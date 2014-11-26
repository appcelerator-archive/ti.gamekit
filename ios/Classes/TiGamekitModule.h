/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "TiModule.h"
#import "TiGamekitLeaderBoardProxy.h"


BOOL isGameCenterAvailable();

@interface TiGamekitModule : TiModule 
{
	TiGamekitLeaderBoardProxy *leaderBoardProxy;
}

@property (nonatomic, retain) TiGamekitLeaderBoardProxy *leaderBoardProxy;

// currentPlayerID is the value of the playerID last time GameKit authenticated.
@property (retain,readwrite) NSString * currentPlayerID;

// isGameCenterAuthenticationComplete is set after authentication, and authenticateWithCompletionHandler's completionHandler block has been run. It is unset when the applicaiton is backgrounded. 
@property (readwrite, getter=isGameCenterAuthenticationComplete) BOOL gameCenterAuthenticationComplete;

BOOL isGameCenterAPIAvailable();
-(BOOL) isPlayerAuthenticated;
@end
