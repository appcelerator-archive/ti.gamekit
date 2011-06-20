/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiGamekitPeerProxy.h"

#import "TiUtils.h"
#import "TiApp.h"

#define kMaxGKPacketSize 1024

@implementation TiGamekitPeerProxy

@synthesize moduleSession;
@synthesize otherPeerId;

-(void)startPicker:(id)args {
	ENSURE_UI_THREAD(startPicker,args);
	GKPeerPickerController*		picker;
	
	//self.gameState = kStatePicker;			// we're going to do Multiplayer!
	
	picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
	picker.delegate = self;
	[picker show]; // show the Peer Picker
}

#pragma mark GKPeerPickerControllerDelegate Methods

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker { 
	// Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
	// autorelease the picker. 
	picker.delegate = nil;
    [picker autorelease]; 
	
	// invalidate and release game session if one is around.
	/*if(self.moduleSession != nil)	{
		[self invalidateSession:self.moduleSession];
		self.moduleSession = nil;
	}
	
	// go back to start mode
	self.gameState = kStateStartGame;
	 */
} 

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type { 
	GKSession *session = [[GKSession alloc] initWithSessionID:@"appcgk" displayName:nil sessionMode:GKSessionModePeer]; 
	return [session autorelease]; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session { 
	// Remember the current peer.
	 self.otherPeerId = peerID;  // copy
	
	// Make sure we have a reference to the game session and it is set up
	self.moduleSession = session; // retain
	self.moduleSession.delegate = self; 
	[self.moduleSession setDataReceiveHandler:self withContext:NULL];
	/* */
	
	// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	[picker autorelease];
	
	[self fireEvent:@"connected"];
	
	// Start Multiplayer game by entering a cointoss state to determine who is server/client.
	//self.gameState = kStateMultiplayerCointoss;
} 

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state { 
	NSLog(@"===== SESSION CHANGE ====== ",state);
	/*if(self.gameState == kStatePicker) {
		return;				// only do stuff if we're in multiplayer, otherwise it is probably for Picker
	}*/
	moduleSession = session;
	
	if(state == GKPeerStateDisconnected) {
		// We've been disconnected from the other peer.
		NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", [session displayNameForPeer:peerID]];
		// Update user alert or throw alert if it isn't already up
		/*NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", [session displayNameForPeer:peerID]];
		if((self.gameState == kStateMultiplayerReconnect) && self.connectionAlert && self.connectionAlert.visible) {
			self.connectionAlert.message = message;
		}
		else { */
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
			//self.connectionAlert = alert;
			[alert show];
			[alert release];
		//}
		
		// go back to start mode
		//self.gameState = kStateStartGame; 
	} else {
		
	}
	
} 

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { 
	NSString *newStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	
	NSLog(@"msg data: %@",newStr);
	
	//NSLog(@"data packet: %@",incomingPacket);
	NSDictionary* event = [NSDictionary dictionaryWithObjectsAndKeys:newStr,@"message",nil];
	[self fireEvent:@"dataRecieved" withObject:event];
}

- (void)sendNetworkPacket:(id)args {
	NSLog(@"arg count %@ ",[args objectAtIndex:1]);
	GKSession *session = moduleSession;//[args objectAtIndex:0];
	
	NSData *messageData = [[args objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
		[session sendData:messageData toPeers:[NSArray arrayWithObject:otherPeerId] withDataMode:GKSendDataReliable error:nil];
	
}

@end
