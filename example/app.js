// open a single window
var window = Ti.UI.createWindow({
    backgroundColor: 'white',
    backgroundImage: 'background.png'
});
var label = Ti.UI.createLabel();

var lb_btn = Ti.UI.createButton({title: 'Show Leader Boards', top: 100, width: 150, height: 45, enabled: false});

var rptScore_btn = Ti.UI.createButton({title: 'Report Score', top: 150, width: 150, height: 45, enabled: false});

var ach_btn = Ti.UI.createButton({title: 'Achievement List', top: 200, width: 150, height: 45, enabled: false});

var send_ach_btn = Ti.UI.createButton({title: 'Send Achievement', top: 250, width: 150, height: 45, enabled: false});

var peer_btn = Ti.UI.createButton({title: 'Show Peers', top: 300, width: 150, height: 45, enabled: false});

var chat_btn = Ti.UI.createButton({title: 'Strt Chat', top: 350, width: 150, height: 45, enabled: false});

var end_chat_btn = Ti.UI.createButton({title: 'End Chat', top: 350, width: 150, height: 45});

window.add(label);
window.open();

var GameKit = require('ti.gamekit');

GameKit.addEventListener('loggedin', function () {

    var gk = GameKit.createLeaderBoard('com.custeng.leaders');
    var gk_ach = GameKit.createAchievements();
    var gk_peer = GameKit.createPeer();
    //this needs to be set for the peer to peer picker to find other peers
    gk_peer.sessionName = "myapp";

    //alert(gk_peer.sessionName);

    lb_btn.enabled = true;

    var isConnected = false;

    lb_btn.addEventListener('click', function () {
        gk.showLeaderBoard();
    });

    window.add(lb_btn);

    rptScore_btn.addEventListener('click', function () {
        var score = 5;
        var category = 'com.custeng.leaders';
        gk.reportScore(score, category);
    });

    window.add(rptScore_btn);

    rptScore_btn.enabled = true;

    ach_btn.addEventListener('click', function () {
        gk_ach.showAchievements();
    });

    window.add(ach_btn);

    ach_btn.enabled = true;

    send_ach_btn.addEventListener('click', function () {
        var identifier = '10_hits_no_miss';
        var perc = 100;
        gk_ach.submitAchievement(identifier, perc);
    });

    window.add(send_ach_btn);

    send_ach_btn.enabled = true;

    peer_btn.addEventListener('click', function () {
        gk_peer.startPicker();
    });

    gk_peer.addEventListener('connected', function (e) {

        if (!isConnected) {
            alert('connected to: ' + e.peerName);
            var data = 'Howdy Partner :)';
            gk_peer.sendGameData(data);

            window.add(chat_btn);
            chat_btn.enabled = true;

            chat_btn.addEventListener('click', function () {
                gk_peer.startVoice();
                chat_btn.hide();

                window.add(end_chat_btn)
                end_chat_btn.addEventListener('click', function () {
                    gk_peer.stopVoice();
                    end_chat_btn.hide();
                    chat_btn.show();
                });
            });
            isConnected = true;
        } else {
            isConnected = false;
            gk_peer.disconnectPeer();
        }

    });

    gk_peer.addEventListener('disconnected', function () {
        peer_btn.enabled = true;
        alert('Disconnected');
    });

    gk_peer.addEventListener('dataRecieved', function (e) {
        alert(e.message);
    });

    window.add(peer_btn);

    peer_btn.enabled = true;
});


