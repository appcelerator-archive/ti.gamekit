/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2011 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <AudioToolbox/AudioToolbox.h>
#import <GameKit/GKVoiceChatService.h>
#import "TiGamekitPeerProxy.h"
#import "TiUtils.h"
#import "TiApp.h"

#define kMaxGKPacketSize 1024

@implementation TiGamekitPeerProxy

@synthesize moduleSession;
@synthesize otherPeerId;
@synthesize enableVoiceChat;

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
	if(self.moduleSession != nil)	{
		[self invalidateSession:self.moduleSession];
		self.moduleSession = nil;
	}
	/*
	// go back to start mode
	self.gameState = kStateStartGame;
	 */
} 

-(BOOL) comparePeerID:(NSString*)peerID
{
    return [peerID compare:moduleSession.peerID] == NSOrderedAscending;
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type { 
	GKSession *session = [[GKSession alloc] initWithSessionID:@"appcgk" displayName:nil sessionMode:GKSessionModePeer]; 
	return [session autorelease]; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session { 
	// Remember the current peer.
	 self.otherPeerId = peerID;  // copy
	[self setupVoice];
	// Make sure we have a reference to the game session and it is set up
	self.moduleSession = session; // retain
	self.moduleSession.delegate = self; 
	[self.moduleSession setDataReceiveHandler:self withContext:NULL];
	/* */
	gameState = ConnectionStateConnected;
	
	otherPeerId = [peerID retain];
	moduleSession.available = NO;
	
	gameState = ConnectionStateConnected;
	
	//}
	NSMutableDictionary *event = [NSMutableDictionary dictionary];
	[event setValue:peerID forKey:@"peerId"];
	[self fireEvent:@"connected" withObject:event];
		// Done with the Peer Picker so dismiss it.
	[picker dismiss];
	picker.delegate = nil;
	[picker autorelease];
	
	// Start Multiplayer game by entering a cointoss state to determine who is server/client.
	//self.gameState = kStateMultiplayerCointoss;
} 

- (void)invalidateSession:(GKSession *)session {
	if(session != nil) {
		[session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
	}
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state { 
	NSLog(@"===== SESSION CHANGE ====== ");
	/*if(self.gameState == kStatePicker) {
		return;				// only do stuff if we're in multiplayer, otherwise it is probably for Picker
	}*/
	moduleSession = session;
	
	if(state == GKPeerStateDisconnected) {
		// We've been disconnected from the other peer.
		[self disconnectCurrentCall];
		 NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", [session displayNameForPeer:peerID]];
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
		//self.connectionAlert = alert;
		[self fireEvent:@"connectionlost"];
		[alert show];
		[alert release];
		
	} else {
		
		
		
	} 
		
} 

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
    if (gameState != ConnectionStateDisconnected) {
        
        // Make self available for a new connection.
		[otherPeerId release];
        otherPeerId = nil;
        moduleSession.available = YES;
        gameState = ConnectionStateDisconnected;
		[self fireEvent:@"connectionfailed"];
    }
}

- (void)session:(GKSession *)session didFailWithError:(NSError*)error
{
    NSLog(@"%@",[error localizedDescription]);
    [self disconnectCurrentCall];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { 
	/*
	*/
	PacketType header;
    uint32_t swappedHeader;
    if ([data length] >= sizeof(uint32_t)) {    
        [data getBytes:&swappedHeader length:sizeof(uint32_t)];
        header = (PacketType)CFSwapInt32BigToHost(swappedHeader);
        NSRange payloadRange = {sizeof(uint32_t), [data length]-sizeof(uint32_t)};
        NSData* payload = [data subdataWithRange:payloadRange];
        
        // Check the header to see if this is a voice or a game packet
        if (header == PacketTypeVoice) {
            [[GKVoiceChatService defaultVoiceChatService] receivedData:payload fromParticipantID:peer];
        } else {
            NSLog(@"------ recv data ------");
			NSString *newStr = [[[NSString alloc] initWithData:payload encoding:NSUTF8StringEncoding] autorelease];
			
			NSLog(@"msg data: %@",newStr);
			
			//NSLog(@"data packet: %@",incomingPacket);
			NSDictionary* event = [NSDictionary dictionaryWithObjectsAndKeys:newStr,@"message",nil];
			[self fireEvent:@"dataRecieved" withObject:event];
			//[newStr release];
			//newStr = nil;
			//[event release];
			//event = nil;
        }
    }
}

- (void)sendNetworkPacket:(NSData*)data ofType:(PacketType)type {
	NSMutableData * newPacket = [NSMutableData dataWithCapacity:([data length]+sizeof(uint32_t))];
    // Both game and voice data is prefixed with the PacketType so the peer knows where to send it.
    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];
    NSError *error;
    if (otherPeerId) {
        if (![moduleSession sendData:newPacket toPeers:[NSArray arrayWithObject:otherPeerId] withDataMode:GKSendDataReliable error:&error]) {
            NSLog(@"%@",[error localizedDescription]);
        }
    }
}

-(void)sendGameData:(id)args{
	NSLog(@"----- GAME DATA ----");
	
	NSData *messageData = [[args objectAtIndex:0] dataUsingEncoding:NSUTF8StringEncoding];
	[self sendNetworkPacket:messageData ofType:PacketTypeData];
}

-(void) disconnectCurrentCall
{	
    if (gameState != ConnectionStateDisconnected) {
        if(gameState == ConnectionStateConnected) {		
            [[GKVoiceChatService defaultVoiceChatService] stopVoiceChatWithParticipantID:otherPeerId];
        }
		[self fireEvent:@"chatended"];
    }
}

-(void)disconnectPeer:(id)args
{
	[moduleSession disconnectFromAllPeers];
	moduleSession.available = YES;
	gameState = ConnectionStateDisconnected;
	[otherPeerId release];
	otherPeerId = nil;
}

void EnableSpeakerPhone ()
{
	NSLog(@"------- ENABLING SPEAKERPHONE -----");
	UInt32 dataSize = sizeof(CFStringRef);
	CFStringRef currentRoute = NULL;
    OSStatus result = noErr;
    
	AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &dataSize, &currentRoute);
    
	// Set the category to use the speakers and microphone.
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    result = AudioSessionSetProperty (
                                      kAudioSessionProperty_AudioCategory,
                                      sizeof (sessionCategory),
                                      &sessionCategory
                                      );	
    assert(result == kAudioSessionNoError);
    
    Float64 sampleRate = 44100.0;
    dataSize = sizeof(sampleRate);
    result = AudioSessionSetProperty (
                                      kAudioSessionProperty_PreferredHardwareSampleRate,
                                      dataSize,
                                      &sampleRate
                                      );
    assert(result == kAudioSessionNoError);
    
	// Default to speakerphone if a headset isn't plugged in.
    UInt32 route = kAudioSessionOverrideAudioRoute_Speaker;
    dataSize = sizeof(route);
    result = AudioSessionSetProperty (
                                      // This requires iPhone OS 3.1
                                      kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                                      dataSize,
                                      &route
                                      );
    assert(result == kAudioSessionNoError);
    
    AudioSessionSetActive(YES);
}

// Called when audio is interrupted by a call or alert.  Since we are using
// UIApplicationWillResignActiveNotification to deal with ending the game,
// this just resumes speakerphone after an audio interruption.
void InterruptionListenerCallback (void *inUserData, UInt32 interruptionState)
{
    if (interruptionState == kAudioSessionEndInterruption) {
        EnableSpeakerPhone();
    }
}


- (void)setupVoice
{
    // Set up audio to default to speakerphone but use the headset if one is plugged in.
    AudioSessionInitialize(NULL, NULL, InterruptionListenerCallback, self);
	EnableSpeakerPhone();
    
    [GKVoiceChatService defaultVoiceChatService].client = self; 
	[[GKVoiceChatService defaultVoiceChatService] setInputMeteringEnabled:YES]; 
	[[GKVoiceChatService defaultVoiceChatService] setOutputMeteringEnabled:YES];
	
	
	//[self fireEvent:@"voicestarted"];
}

-(void)startVoice:(id)args
{
	NSError *error; 
	if (![[GKVoiceChatService defaultVoiceChatService] startVoiceChatWithParticipantID:[self otherPeerId] error:&error]) {
		NSLog(@"%@",[error localizedDescription]);
	} else {
		[self fireEvent:@"chatstarted"];
	}

}

-(void)stopVoice:(id)args
{
	[self disconnectCurrentCall];
}

// GKVoiceChatService Client Method. For convenience, we are using the same ID for the GKSession and GKVoiceChatService.
- (NSString *)participantID
{
	return moduleSession.peerID;
}

// GKVoiceChatService Client Method. Sends voice data over the GKSession to the peer.
- (void)voiceChatService:(GKVoiceChatService *)voiceChatService sendData:(NSData *)data toParticipantID:(NSString *)participantID
{
	
  	[self sendNetworkPacket:data ofType:PacketTypeVoice]; 
}

// GKVoiceChatService Client Method. Received a voice chat invitation from the connected peer.
- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didReceiveInvitationFromParticipantID:(NSString *)participantID callID:(NSInteger)callID
{
	NSLog(@" ----- CHAT SERVICE RECV INVITATION -----");
	if ([self isReadyToStart]) {
		NSLog(@"------------ READY TO START -----------");
		NSError *error;
		if (![[GKVoiceChatService defaultVoiceChatService] acceptCallID:callID error:&error]) {
            NSLog(@"%@",[error localizedDescription]);
            [self disconnectCurrentCall];
        }
	} else {
		[[GKVoiceChatService defaultVoiceChatService] denyCallID:callID];
		[self disconnectCurrentCall];
	}
}

// GKVoiceChatService Client Method. In the event something weird happened and the voice chat failed, disconnect.
- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didNotStartWithParticipantID:(NSString *)participantID error:(NSError *)error
{
    NSLog(@"%@",[error localizedDescription]);
    [self disconnectCurrentCall];
}

// GKVoiceChatService Client Method. The voice chat with the connected peer successfully started.
- (void)voiceChatService:(GKVoiceChatService *)voiceChatService didStartWithParticipantID:(NSString *)participantID
{
	NSLog(@"--------- CHAT STARTED ----------");
}

-(BOOL) isReadyToStart
{
    return gameState == ConnectionStateConnected;
}

@end
