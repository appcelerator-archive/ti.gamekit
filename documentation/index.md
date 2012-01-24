# Ti.GameKit Module

## Description
This is a module that integrates Apple's Game Kit API. Currently Leader Boards and Achievements are supported.

Once the module instance is created, the current player is automatically authenticated. If the current player has a 
current session iOS displays a Weclome Back PlayerName dialog.

If the current player does not have a current session a dialog is displayed by iOS that has the option of creating a 
new game center account, or use an existing one or cancel the dialog. 

If the player creates a new account, iOS has takes over until the process is done and then it returns player data back 
to your app. After either a successful account creation or a  successful log in, a loggedin event is fired. At this
point, your app is now ready to use the following methods.

## Getting Started

View the [Using Titanium Modules](https://wiki.appcelerator.org/display/tis/Using+Titanium+Modules) document for instructions on getting
started with using this module in your application.

## Accessing the Ti.GameKit Module
To access this module from JavaScript, you would do the following:

<pre>var GameKit = require('ti.gamekit');</pre>

## Methods

### bool isAvailable()
Checks if GameKit is available on the current device. Devices must be running iOS 4.1 or later.

### [Ti.GameKit.LeaderBoard][] createLeaderBoard()
Creates a LeaderBoard GUI to display to your users.

Takes the following arguments:

* string identifier: The identifier for a leaderboard that you set up in your iTunes Connect portal for this app.

### [Ti.GameKit.Achievements][] createAchievements()
Controls achievements that your users earn over time in GameKit.

Does not take any arguments.

### [Ti.GameKit.Peer][] createPeer()
Creates the Peer to Peer UI for interactive gaming, giving you several APIs for programmatic communication between devices.

Does not take any arguments.

## Events

### loggedIn
Fired when the current user is identified and logged in.

### notLoggedIn
Fired when the user is not logged in to GameKit.

## Usage
See example.

## Author
Clint Tredway & Dawson Toth

## Module History
View the [change log](changelog.html) for this module.

## Feedback and Support
Please direct all questions, feedback, and concerns to [info@appcelerator.com](mailto:info@appcelerator.com?subject=iOS%20GameKit%20Module).

## License
Copyright(c) 2010-2011 by Appcelerator, Inc. All Rights Reserved. Please see the LICENSE file included in the distribution for further details.

[Ti.GameKit.LeaderBoard]: leaderboard.html
[Ti.GameKit.Peer]: peer.html
[Ti.GameKit.Achievements]: achievements.html
