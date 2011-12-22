# Ti.GameKit.Achievements

## Description
Controls the GameKit LeaderBoard GUI.

## Methods

### void showAchievements()
Shows the iOS Achievements dialog, where users can see all of their earned achievements. This UI cannot be customized.

### void submitAchievement(string identifier, float percentageEarned)
Updates the user's progress on an achievement.

Takes the following arguments:

* string identifier: The identifier you set up in your iTunes Connect account for this app.
* float percentageEarned: A float from 0 to 100 describing how close the user is to completing the achievement. Once reported, achievements cannot be downgraded (so if a user completes 50% of an achievement, you cannot kick them back to only 10% completed).

### void resetAchievements()
Resets the user' achievements for this app.

## Events

### earned
Fired when the user fully earns an achievement.

Receives a dictionary with the following key:

* string identifier: The identifier for the earned achievement.

### progress
Fired when the user makes progress towards an achievement.
                                                          
Receives a dictionary with the following key:

* string identifier: The identifier for the progressed achievement.

### reset
Fired when the user's achievements have been successfully reset.

### error
Fired when a server interaction fails.
                                                                                                                  
Receives a dictionary with the following key:

* NSError error: The encountered error.