// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'white'
});

var lb_btn = Ti.UI.createButton({title:'Show Leader Boards',top:100,width:150,height:45,enabled:false});

var rptScore_btn = Ti.UI.createButton({title:'Report Score',top:150,width:150,height:45,enabled:false});

var ach_btn = Ti.UI.createButton({title:'Achievement List',top:200,width:150,height:45,enabled:false});

var send_ach_btn = Ti.UI.createButton({title:'Send Achievement',top:250,width:150,height:45,enabled:false});

// init the module. This will either show a dialog to log in/create an account or a dialog that welcomes the plater back
var gamekit = require('ti.gamekit');
Ti.API.info("module is => " + gamekit);

//once a player is logged in, this event will fire
gamekit.addEventListener('loggedin',function(){
	//this inits the leader board UI - only needed if your app has one or more leader boards setup in iTunes Connect for the app
	var gk = gamekit.createLeaderBoard('com.custeng.leaders');
    
    //this inits the Achievements UI - only needed if your app has one or more achievements setup in iTunes Connect for the app
	var gk_ach = gamekit.createAchievements();
    
	lb_btn.enabled = true;
	
	lb_btn.addEventListener('click',function(){
        //this is what makes the Leader Board Dialog show up
		gk.showLeaderBoard();
	});

	window.add(lb_btn);
	
	rptScore_btn.addEventListener('click',function(){
        //this is what sends a score to Apple. the category is really a leader board you want the score to report against, sort of misleading
		var score = 5;
		var category = 'com.custeng.leaders';
		gk.reportScore(score,category);
	});
    
    gk.addEventListener('score_submitted',function(){
        //this will fire once a score has been submitted
    });
	
	window.add(rptScore_btn);
	
	rptScore_btn.enabled = true;
	
	ach_btn.addEventListener('click',function(){
        //this is what shows the Achievements Dialog
		gk_ach.showAchievements();
	});
	
	window.add(ach_btn);
	
	ach_btn.enabled = true;
	
	send_ach_btn.addEventListener('click',function(){
        //this submits an achievement
		var identifier = '10_hits_no_miss';
		var perc = 100;
		gk_ach.submitAchievement(identifier,perc);
	});
    
    gk_ach.addEventListener('achievement_earned',function(){
        //this will fire when an achievement has been fully earned
    });
    
    gk_ach.addEventListener('achievement_progress',function(){
        //this will fire when an achievement has been partially earned
    });
    
    gk_ach.addEventListener('achievement_failed',function(){
        //this will fire when an achievement has failed after being sent to Apple
    });
	
	window.add(send_ach_btn);
	
	send_ach_btn.enabled = true;
});

window.open();
