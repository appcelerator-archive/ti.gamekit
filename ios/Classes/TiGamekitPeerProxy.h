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

typedef enum {
    PacketTypeVoice = 0,
    PacketTypeData = 1,
    PacketTypeBounce = 2,
    PacketTypeScore = 3,
    PacketTypeTalking = 4,
    PacketTypeEndTalking = 5
	
} PacketType;

typedef enum {
    ConnectionStateDisconnected,
    ConnectionStateConnecting,
    ConnectionStateConnected
} ConnectionState;

@interface TiGamekitPeerProxy : TiProxy<GKPeerPickerControllerDelegate> {
	GKSession *moduleSession;
	NSString *otherPeerId;
	NSString *sessionName;
	int		gamePacketNumber;
	ConnectionState	gameState;
}

@property(nonatomic, retain) GKSession	 *moduleSession;
@property(nonatomic, copy)	 NSString	 *otherPeerId;
@property(nonatomic,retain) NSString	 *sessionName;

-(void)invalidateSession:(GKSession *)session;
-(void)setupVoice;
-(void)disconnectCurrentCall;
-(BOOL)isReadyToStart;
-(void)disconnectPeer:(id)args;

@end
