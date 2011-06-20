/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <GameKit/GameKit.h>

typedef struct {
	StringPtr message;
} messageInfo;

@interface TiGamekitPeerProxy : TiProxy<GKPeerPickerControllerDelegate> {
	GKSession *moduleSession;
	NSString *otherPeerId;
	int		gamePacketNumber;
}

@property(nonatomic, retain) GKSession	 *moduleSession;
@property(nonatomic, copy)	 NSString	 *otherPeerId;

@end
