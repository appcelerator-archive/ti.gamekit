<font face="verdana,helvetica">
# iOS Game Kit Module

## Description

This is a module that integrates Apple's Game Kit API. Currently Leader Boards and Achievements are supported.

## Accessing the gamekit Module

To access this module from JavaScript, you would do the following:

	var gamekit = require("ti.gamekit");

The gamekit variable is a reference to the Module object.
Once the module instance is created, the current player is automatically authenticated. If the current player has a current session iOS displays a Weclome Back PlayerName dialog. 
If the current player does not have a current session a dialog is displayed by iOS that has the option of creating a new game center account, or use an existing one or cancel the dialog. 
If the player creates a new account, iOS has takes over until the process is done and then it returns player data back to your app. After either a successful account creation or a 
successful log in, a loggedin event is fired. At this point, your app is now ready to use the following methods.

## Leader Board API

There are two main functions in the Game Kit module:<br/>
createLeaderBoard() & createAchievements()

### createLeaderBoard()

The signature for this method is createLeaderBoard('someLeaderBoard');
The leader board that is passed in is a leader board that is set up in your iTunes Connect portal for this app.
Once this is created the iOS Leader Board UI is now available for show. 

### showLeaderBoard()

This is the function that is used to make the iOS Leader Board UI show to the user.
All of the Leader Boards that are setup in your iTunes Connect are available here. This is a read only UI.

To dismiss the dialog the UI has a built in Done button that will dismiss the dialog. 
The createLeaderBoard() method has to be called first.

### reportScore()
The signature for this method is: reportScore(score,category)<br/>
Score is the score you want to submit to game center<br/>
Category is the Leader Board that you want to submit the score for.<br/>
<br/>
A scoreSubmitted event is fired after the score has been sent to Game Center.<br/>
<br/>
Example:<br/>
	var score = 5;<br/>
	var category = '## YOUR LEADER BOARD HERE ##';<br/>
	gamekit.reportScore(score,category);<br/>
<br/>
## Achievements API

### createAchievements()
This function does not take any arguments and creates an instance of the iOS GKAchievements class.

### showAchievements()
This function creates an instance of the iOS Achievements diaglog. This will be a table view of all the Achievements that have been created for your app in your iTunes Connect. This is a read only UI. 
To dismiss the dialog there is a built in Done button. 

### submitAchievement()
The signature for this method is: submitAchievement(identifier,perc)<br/>
Identifier is an achievement that is setup in your iTunes Connect account for this app.<br/>
Perc is the percent complete for the given achievement. Once an achievement has been fully earned it will be shown as achieved in the Achievements UI.<br/>
<br/>
This has three events that may fire once an achievement is submitted.<br/>
<br/>
If fully earned: 'achievementEarned' <br/>
If partially earned: 'achievementProgress'<br/>
If submission failed: 'achievementFailed'<br/>
<br/>
Example:<br/>
	var identifier = '## YOUR ACHIEVEMENT HERE ###';	<br/>
	var perc = 100;<br/>
	gk_ach.submitAchievement(identifier,perc);<br/>
<br/>

## Peer API

### createPeer()
This method is what starts the Peer to Peer UI that searches for other users. Once 2 devices are connected, a connected event will fire. At that point game releated data can be
exchanged. Including plain text or JSON.

### sessionName
This is a property (string) that has to be set in order for the peer picker to properly detect other peers for your application.

### sendGameData(data)
This method sends text or JSON through to another connected client. This can be used for text chats or game data.

### startVoice()
This will start voice chat with the connected peer.

### stopVoice()
This stops a voice chat session

### disconnectPeer()
This will end a game session with a connected peer

## Peer Events
### connected(object event)
This fires once connected to another peer
Returns the peerID and peerName both of which are strings.

###disconnected
Fires when the disconnectPeer() method is called

###dataRecieved(string data)
This fires when data is recieved from a connected peer. This is a string which means you can send plain text or JSON.
the variable 'message' is what the data is in and its a string.

###chatstarted
Fires when a voice chat is started

###chatended
Fires when a voice chat is stopped

## Usage

See the app.js file in the example directory

</font>


## License

Copyright(c) 2010-2011 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.
