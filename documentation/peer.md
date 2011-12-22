# Ti.GameKit.Peer

## Description
Controls the GameKit Peer interfaces.

When created, this launches the Peer to Peer UI that searches for other users. Once 2 devices are connected, a connected
event will fire. At that point game related data can be exchanged (including plain text or JSON).

## Properties

### string sessionName
Identifies your application to the GameKit Peer interactions.

## Methods

### sendGameData(data)
This method sends text or JSON through to another connected client. This can be used for text chats or game data.

### startVoice()
This will start voice chat with the connected peer.

### stopVoice()
This stops a voice chat session

### disconnectPeer()
This will end a game session with a connected peer

## Events

### connected(object event)

This fires once connected to another peer

Receives a dictionary with the following keys:

* string peerID
* string peerName

### disconnected
Fires when the disconnectPeer() method is called.

### dataReceived(string data)
This fires when data is received from a connected peer. This is a string which means you can send plain text or JSON.
the variable 'message' is what the data is as string.

###chatstarted
Fires when a voice chat is started

###chatended
Fires when a voice chat is stopped
