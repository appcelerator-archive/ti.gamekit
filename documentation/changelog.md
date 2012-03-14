# Change Log
<pre>
v1.4	Fixed a bug that prevented several of the "error" events from firing while interacting with achievements or the leaderboard. [MOD-533] 

v1.3	Fixed reportScore's documentation and example to properly use its arguments (should be category, then score). [MOD-438]

v1.2	Updated documentation to warn about the LeaderBoard only displaying with 2 or more reported scores. [MOD-366]
		Fixed the example to properly call showLeaderBoard(identifier). It was missing the identifier. [MOD-366]
		Added an alert to the example to exclaim when a score has finished reporting.
		Added better validation to LeaderBoard and Achievements. [MOD-366]

v1.1	Updated documentation for greater clarity and consistency with other Titanium modules.
		Fixed achievements. [MOD-327]
		Added the "isAvailable()" method to the module.
		BREAKING CHANGE: Renamed the "loggedin" event to "loggedIn" (with an upper case I) for platform consistency.
		Added the new "notLoggedIn" event.
		BREAKING CHANGE: Renamed "dataRecieved" event to "dataReceived" (spelling fix).
		
v1.0    Initial Release
