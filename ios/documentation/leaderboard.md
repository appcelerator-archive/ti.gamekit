# Ti.GameKit.LeaderBoard

## Description
Controls the GameKit LeaderBoard GUI.

## Warning
The LeaderBoard will not show anything until at least 2 users have reported scores for a particular identifier.

## Methods

### void showLeaderBoard(string identifier)
Shows a particular LeaderBoard to the user.

Accepts a single argument:

* string identifier: The identifier for the LeaderBoard, as set up in your iTunesConnect for this app.

### reportScore(string identifier, int score)
Saves a score for the current user to the specified LeaderBoard
                                                               
Accepts two arguments:

* string identifier: The identifier for the LeaderBoard, as set up in your iTunesConnect for this app.
* int score: The score the user accomplished.

## Events

### scoreSubmitted
Fired after a score is successfully reported to Game Center.

### error
Fired when a server interaction fails.
																											   
Receives a dictionary with the following key:

* string error: The encountered error.