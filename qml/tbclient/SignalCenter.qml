import QtQuick 1.1
import "../js/LinkDecoder.js" as LinkDecoder

QtObject {
    id: signalCenter;

    property variant vcodeDialogComp: null;
    property variant newVCodeDialogComp: null;
    property variant queryDialogComp: null;
    property variant enterDialogComp: null;
    property variant copyDialogComp: null;
    property variant commDialogComp: null;
    property variant goodDialogComp: null;
    property variant emotDialogComp: null;
    property variant threadPage: null;
    property variant emoticonModel: [];

    signal userChanged;
    signal userLogout;
    signal vcodeSent(variant caller, string vcode, string vcodeMd5);
    signal imageSelected(variant caller, string urls);
    signal emoticonSelected(variant caller, string name);
    signal friendSelected(variant caller, string name);
    signal forumSigned(string fid);
    signal bookmarkChanged;
    signal profileChanged;

    signal uploadFinished(variant caller, string response);
    signal uploadFailed(variant caller);

    // Common functions
    function showMessage(msg){
        if (msg||false){
            infoBanner.text = msg;
            infoBanner.open();
        }
    }

    function linkClicked(link){
        LinkDecoder.linkActivated(link);
    }

    function clearLocalCache(){
        mainPage.forceRefresh = true;
        utility.clearUserData();
        utility.clearCookies();
    }

    // Dialogs
    function needVCode(caller, vcodeMd5, vcodePicUrl){
        if (!vcodeDialogComp){
            vcodeDialogComp = Qt.createComponent("Dialog/VCodeDialog.qml");
        }
        var prop = { caller: caller, vcodeMd5: vcodeMd5, vcodePicUrl: vcodePicUrl }
        vcodeDialogComp.createObject(pageStack.currentPage, prop);
    }

    function needVCodeNew(caller, vcodeMd5, vcodePicUrl){
        if (!newVCodeDialogComp){
            newVCodeDialogComp = Qt.createComponent("Dialog/NewVCodeDialog.qml");
        }
        var prop = { caller: caller, vcodeMd5: vcodeMd5, vcodePicUrl: vcodePicUrl }
        newVCodeDialogComp.createObject(pageStack.currentPage, prop);
    }

    function createQueryDialog(title, message, acceptText, rejectText, acceptCallback, rejectCallback){
        if (!queryDialogComp){ queryDialogComp = Qt.createComponent("Dialog/DynamicQueryDialog.qml"); }
        var prop = { titleText: title, message: message.concat("\n"), acceptButtonText: acceptText, rejectButtonText: rejectText };
        var diag = queryDialogComp.createObject(pageStack.currentPage, prop);
        if (acceptCallback) diag.accepted.connect(acceptCallback);
        if (rejectCallback) diag.rejected.connect(rejectCallback);
    }

    function createEnterThreadDialog(title, isfloor, pid, tid, fname, fromSearch){
        if (!enterDialogComp){ enterDialogComp = Qt.createComponent("Dialog/EnterThreadDialog.qml"); }
        var prop = { title: title, isfloor: isfloor, pid: pid, tid: tid, fname: fname };
        if (fromSearch) prop.fromSearch = true;
        enterDialogComp.createObject(pageStack.currentPage, prop);
    }

    function copyToClipboard(text){
        if (!copyDialogComp){ copyDialogComp = Qt.createComponent("Dialog/CopyDialog.qml"); }
        var prop = { text: text };
        copyDialogComp.createObject(pageStack.currentPage, prop);
    }

    function commitPrison(prop){
        if (!commDialogComp) commDialogComp = Qt.createComponent("Dialog/CommitDialog.qml");
        commDialogComp.createObject(pageStack.currentPage, prop);
    }

    function commitGoodList(list, callback){
        if (!goodDialogComp) goodDialogComp = Qt.createComponent("Dialog/GoodListDialog.qml");
        var diag = goodDialogComp.createObject(pageStack.currentPage);
        list.forEach(function(value){ diag.model.append(value); });
        diag.goodSelected.connect(callback);
        diag.open();
    }

    function createEmoticonDialog(caller){
        if (!emotDialogComp){
            emotDialogComp = Qt.createComponent("Dialog/EmoticonSelector.qml");
            var fill = function(num){ return num <10 ? "0"+num : num };
            var list = [], i = 0;
            list.push("image_emoticon");
            for (i=2; i<=50; i++) list.push("image_emoticon"+i);
            for (i=1; i<=62; i++) list.push("b"+fill(i));
            for (i=1; i<=70; i++) list.push("ali_0"+fill(i));
            for (i=1; i<=40; i++) list.push("t_00"+fill(i));
            for (i=1; i<=46; i++) list.push("yz_0"+fill(i));
            for (i=1; i<=25; i++) list.push("B_00"+fill(i));
            emoticonModel = list;
        }
        var prop = { caller: caller }
        emotDialogComp.createObject(pageStack.currentPage, prop);
    }

    // Pages
    function needAuthorization(forceLogin){
        if(pageStack.currentPage.objectName !== "LoginPage"){
            var prop = { forceLogin: forceLogin||false }
            pageStack.push(Qt.resolvedUrl("LoginPage.qml"), prop);
        }
    }

    function readMessage(param){
        switch (param){
        case "fans":
        case "bookmark":
            pageStack.push(Qt.resolvedUrl("ProfilePage.qml"), { uid: tbsettings.currentUid });
            break;
        case "pletter":
        case "replyme":
        case "atme":
            var p = pageStack.find(function(page){ return page.objectName === "MessagePage" });
            if (!p) pageStack.push(Qt.resolvedUrl("Message/MessagePage.qml"), { defaultTab: param });
            else if (pageStack.currentPage !== p) pageStack.pop(p);
            break;
        }
    }

    function enterForum(name){
        var p = pageStack.find(function(page){return page.objectName === "ForumPage" && page.name === name});
        if (p) pageStack.pop(p);
        else pageStack.push(Qt.resolvedUrl("Forum/ForumPage.qml"), { name: name });
    }

    /**
      enterThread:
      option: jsobject, optional, if specified, a new thread will be created.

      option should include:
      threadId: string[number], required, id of the thread
      title: string, optional, title of the thread
      isLz: boolean, optional, replies should be filtered by author or not
      fromBookmark: boolean, optional, thread is from bookmark or not
      pid: string[number], optional, if specified, the thread will start by this pid
    */
    function enterThread(option){
        if (!threadPage)
            threadPage = Qt.createComponent("Thread/ThreadPage.qml").createObject(app);
        if (pageStack.currentPage !== threadPage){
            if (pageStack.currentPage.objectName === "MessagePage"
                    && pageStack.find(function(page){ return page === threadPage }))
            {
                pageStack.pop(threadPage);
            } else {
                pageStack.push(threadPage);
            }
        }
        // must be placed after pageStack has set
        if (option){
            threadPage.addThreadView(option);
        }
    }

    function enterFloor(tid, pid, spid, managerGroup){
        var prop;
        if (pid) prop = { threadId: tid, postId: pid };
        else if (spid) prop = { threadId: tid, spostId: spid };
        if (managerGroup) prop.managerGroup = managerGroup;
        pageStack.push(Qt.resolvedUrl("Floor/FloorPage.qml"), prop);
    }

    function viewProfile(uid){
        pageStack.push(Qt.resolvedUrl("ProfilePage.qml"), { uid: uid });
    }

    function viewImage(url){
        if (tbsettings.browser == ""){
            pageStack.push(Qt.resolvedUrl("ImageViewer.qml"), { imageUrl: url })
        } else {
            utility.openURLDefault(url);
        }
    }

    function openBrowser(url){
        if (tbsettings.browser == ""){
            pageStack.push(Qt.resolvedUrl("Browser/WebPage.qml"), {url: utility.percentDecode(url)});
        } else {
            utility.openURLDefault(url);
        }
    }
}
