<!DOCTYPE html>
<html>
    <head>
        <title>runner</title>
        <meta charset="utf-8" />
        <link rel="stylesheet" type="text/css" href="css/runner-theme-w.css" />
        <link rel="stylesheet" type="text/css" href="css/jquery.mobile.icons.min.css" />
        <link rel="stylesheet" type="text/css" href="css/jquery.mobile.structure-1.4.5.css" />
        <link rel="stylesheet" type="text/css" href="css/runner.css" />
        <script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
        <script type="text/javascript" src="js/jquery.mobile-1.4.5.min.js"></script>
        
        <script type="text/javascript" src="js/cordova.js"></script>
        <script type="text/javascript" charset="utf-8" src="js/api.nfcPlugin.js"></script>

	</head>

    <body>


    	<div data-role="page" id="login">
            <script type="text/javascript">

                function loginSubmit(userid, password) {
                    // clear the login result
                    $("#login-result").text("");
                    
                    $.ajax({
                        url: "login",
                        type: "post",
                        data: {
                            userid: userid,
                            password: password
                        },
                        datatype: "json",
                        async: true,
                        crossDomain: true,
                        success: function(result) {
                            if (result["success"] == true) {
                                // 自动记录上次登陆的记录，下次就不用再输入密码了
                                window.localStorage.setItem("savedUserid", userid);
                                window.localStorage.setItem("savedPassword", password);

                                var userData = result.userdata;

                                $("#userNameHead").text(userData.name);
                                
                                $("#duration-summary").text(userData.summary.duration);
                                $("#energy-summary").text(userData.summary.energy);
                                $("#co2-summary").text(userData.summary.energy * 10);   // 此处修改换算公式
                                $("#energy-rank-summary").text(userData.summary.globalRank);

                                $("#duration-average").text(userData.average.duration);
                                $("#energy-average").text(userData.average.energy);
                                $("#co2-average").text(userData.average.energy * 10);
                                $("#energy-rank-average").text(userData.average.globalRank);

                                // 如果上个月有记录，则显示出来 
                                if (userData.lastMonthSummary) {
                                    $("#duration-lastMonth").text(userData.lastMonthSummary.duration);
                                    $("#energy-lastMonth").text(userData.lastMonthSummary.energy);
                                    $("#co2-lastMonth").text(userData.lastMonthSummary.energy * 10);
                                    $("#energy-rank-lastMonth").text(userData.lastMonthSummary.globalRank);
                                }

                                // 如果这个月有锻炼记录，则显示出来
                                if (userData.thisMonthSummary) {
                                    $("#duration-thisMonth").text(userData.thisMonthSummary.duration);
                                    $("#energy-thisMonth").text(userData.thisMonthSummary.energy);
                                    $("#co2-thisMonth").text(userData.thisMonthSummary.energy * 10);
                                    $("#energy-rank-thisMonth").text(userData.thisMonthSummary.globalRank);
                                }
                                
                                window.location.href = "#user_home_page";
                            } else {
                                $("#login-result").text("user name or password error.");
                            }
                        }
                    });
                }

                function autoLogin() {
                    var userid = window.localStorage.getItem("savedUserid");
                    if (userid != null && userid != "") {
                        var password = window.localStorage.getItem("savedPassword");
                        
                        // 提示一下当前登陆的帐号
                        $("#login-user-name").text(userid);
                        loginSubmit(userid, password);
                    }
                }

                $(document).ready(function(){
                    $("#loginSubmit").click(function() {
                        var userid = $("#login-user-name").val();
                        var password = $("#login-password").val();
                        loginSubmit(userid, password);
                    });

                    autoLogin();
                });

            </script>
    		<div data-role="header">
                <a href="#about" data-rel="dialog" data-transition="pop"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">About</a>
                <h1>Login</h1>
            </div>
            <div data-role="content">
            	<form>
                    <input id="login-user-name" name="login-user-name" type="text" data-clear-btn="true"
                        placeholder="User name" />
                    <input id="login-password" name="login-password" type="password" data-clear-btn="true" 
                        placeholder="Password" />
                    <a id="loginSubmit" class="ui-btn ui-corner-all">Login</a>
                    <a href="#sign_up_page" class="ui-btn ui-corner-all">Sign up</a>
                </form>

                <p id="login-result" style="color:red;"></p>
            </div>
    	</div>

        <div data-role="page" id="about">
            <div data-role="header">
                <h1>About this app</h1>
            </div>
            <div data-role="content">
                <p>App for user to access our system. Thanks.</p>
            </div>
        </div>

        <div data-role="page" id="user_home_page" data-position="fixed" data-tap-toggle="false">
            <script type="text/javascript">
                
                var IntvId = 0;
                var StartSecStamp = 0;
                var EndSecStamp = 0;
                var EquipmentId = "";
                var mifareDefaultKey = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff];

                function updateDurationDisp() {
                    var myDate = new Date();
                    var currentMillis = myDate.getTime();
                    var currentSecCount = currentMillis / 1000 - StartSecStamp;
                    var currentMinCount = currentSecCount / 60;
                    $("#exercise-duration-sec").text(parseInt(currentSecCount % 60));
                    $("#exercise-duration-hour").text(parseInt(currentMinCount / 60));
                    $("#exercise-duration-min").text(parseInt(currentMinCount % 60));
                }

                function uploadExRecord(exerciseData) {
                    $.ajax({
                        url: "uploadExRecord",
                        type: "post",
                        data: exerciseData,
                        datatype: "json",
                        async: true,
                        crossDomain: true,
                        success: function(result) {
                            if (result.success) {
                                alert("upload ok!");
                            } else {
                                alert("upload fail");
                            }
                        }
                    });
                }

                // 调用了此回调函数表示nfc读取成功
                // 处理解码后的卡信息，从中读取运动设备信息
                // 记录运动设备信息和运动量信息，并显示
                // 同时维护按钮内容的显示
                function startEx_startTimeInfoProc(code) {
                    console.log(code);

                    // 如果qrcode读取成功，处理完信息后将按钮转变成停止功能
                    $("#start-exercise-btn").text("Stop exercising");

                    var myDate = new Date();
                    var currentMillis = myDate.getTime();
                    StartSecStamp = currentMillis / 1000;
                    IntvId = window.setInterval(updateDurationDisp, 1000);

                    // 从code中读出EquipmentId
                    EquipmentId = "bike001";
                    
                    // display the dashboard
                    $("#exercise-achievement-thisTime").slideUp();
                    $("#exercise-timer").slideDown();
                }
                function stopEx_endTimeInfoProc(code) {
                    console.log(code);
                    if (code == null) {
                        alert("Your exercise has been cancled");
                    }

                    // 如果qrcode读取成功，处理完信息后将按钮转变成停止功能
                    $("#start-exercise-btn").text("Start to exercise");

                    // 停止计时，并标记这个定时器id为0，以便其余时候可以检测是否正在锻炼
                    window.clearInterval(IntvId);
                    IntvId = 0;  
                    var myDate = new Date();
                    var currentMillis = myDate.getTime();
                    EndSecStamp = currentMillis / 1000;

                    // 将解码的code打包到exerciseData
                    var startTime = new Date(StartSecStamp * 1000);
                    var endTime = new Date(EndSecStamp * 1000);
                    var startTimeStr = startTime.getFullYear() + "-" + (startTime.getMonth() + 1) + "-" + startTime.getDate()
                            + " " + startTime.getHours() + ":" + startTime.getMinutes() + ":" + startTime.getSeconds();   
                    var endTimeStr = endTime.getFullYear() + "-" + (endTime.getMonth() + 1) + "-" + endTime.getDate()
                            + " " + endTime.getHours() + ":" + endTime.getMinutes() + ":" + endTime.getSeconds();   
                    
                    var userid = window.localStorage.getItem("savedUserid");
                    var exerciseData = {
                        userid: userid,
                        startTime: startTimeStr,
                        endTime: endTimeStr,
                        energy: 0.12,
                        peakPower: 450.1,
                        efficiency: 0.78,
                        peakCurrent: 12.1,
                        peakVoltage: 45.7,
                        co2reduced: 123.1,
                        equipmentid: EquipmentId
                    };
                    uploadExRecord(exerciseData);

                    // 上传完后把对应内容显示出来
                    $("#startTime-thisEx").text(startTime.toLocaleTimeString());
                    $("#endTime-thisEx").text(endTime.toLocaleTimeString());

                    // 计算持续时间
                    var durationInMin = (EndSecStamp - StartSecStamp) / 60;
                    $("#duration-hour-thisEx").text(parseInt(durationInMin / 60));
                    $("#duration-min-thisEx").text(parseInt(durationInMin % 60));

                    $("#energy-thisTime").text(exerciseData.energy);
                    $("#peak-power-thisTime").text(exerciseData.peakPower);
                    $("#efficiency-thisTime").text(exerciseData.efficiency);
                    $("#co2-reduced-thisTime").text(exerciseData.energy * 10);  // 换算得到
                    
                    // display the dashboard
                    $("#exercise-achievement-thisTime").slideDown();
                    $("#exercise-timer").slideUp();
                }

                function exerciseCommand(command) {
                    var success = function(data) {  
                        alert("card id:\n" + data.cardId);  
                        var sector1str = "";
                        for (var i = 32; i < 48; ++i) {
                            sector1str += data.cardData[i].toString(16) + " ";
                        }
                        alert("block 2:\n" + sector1str);
                        sector1str = "";
                        for (var i = 48; i < 64; ++i) {
                            sector1str += data.cardData[i].toString(16) + " ";
                        }
                        alert("ctrl block:\n" + sector1str);

                        if (command == "start") {
                            startEx_startTimeInfoProc("[put exercise info here]");
                        } else if (command == "stop") {
                            stopEx_endTimeInfoProc("[put exercise info here]");
                        }
                    };  
                    var error = function(e) {  
                        alert(e.reason);  
                    };  
                    
                    var lock = [];
                    if (command == "start") {
                        lock = [
                            {
                                blockIndex: 4,
                                data: [0xff, 0xff, 0x01, 0x02]
                            }
                        ];
                    } else {
                        lock = [
                            {
                                blockIndex: 4,
                                data: [0x00, 0x00, 0x00, 0x00]
                            }
                        ];
                    }
                    window.plugins.nfc.readThenWrite(success, error, mifareDefaultKey, lock);
                }


                function signOut() {
                    // 自动取消本次锻炼，本次锻炼信息作废
                    if (IntvId != 0) {
                        stopEx_endTimeInfoProc(null);
                    }
                    
                    // 隐藏本次锻炼的信息
                    $("#exercise-achievement-thisTime").slideUp();
                    $("#exercise-timer").slideUp();
                    
                    // 登出的时候自动清除保存的帐号和密码
                    window.localStorage.setItem("savedUserid", null);
                    window.localStorage.setItem("savedUserid", null);
                    window.localStorage.setItem("savedPassword", null);
                    window.localStorage.setItem("savedPassword", null);
                }



                $(document).ready(function() {
                    $("#signOutBtn").click(signOut);
                    $("#start-exercise-btn").click(function() {
                        if ($(this).text().indexOf("Start") >= 0) {
                            exerciseCommand("start");
                        } else if ($(this).text().indexOf("Stop") >= 0) {
                            exerciseCommand("stop");
                        }

                        // 刚按开始运动或者结束运动后，按钮会禁用1.5s
                        // 避免信息尚未读取或处理成功又进行了第二次读取或处理
                        $(this).attr("disabled", true);
                        window.setTimeout(function() {
                            $("#start-exercise-btn").removeAttr("disabled");
                        }, 1000);
                    });
                });

            </script>
            <div data-role="header">
                <a href="#login" id="signOutBtn"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">Sign out</a>
                <h1 id="userNameHead">[name]</h1>
                <a href="user_exercise_history" data-ajax="false" id="user-ex-history-btn"
                    class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all">History</a>
            </div>
            <div data-role="content">
                <table data-role="table" data-mode="columntoggle" class="ui-responsive table-stroke">
                    <thead>
                        <tr>
                            <th>Achievement</th>
                            <th data-priority="1">Duration</th>
                            <th data-priority="1">Energy</th>
                            <th data-priority="2">CO<small>2</small> reduced</th>
                            <th data-priority="3">Rank</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Summary</td>
                            <td><span id="duration-summary">10h 12min</span></td>
                            <td><span id="energy-summary">100</span> kWh</td>
                            <td><span id="co2-summary">1.2</span> kg</td>
                            <td><span id="energy-rank-summary">1</span></td>
                        </tr>
                        <tr>
                            <td>Average</td>
                            <td><span id="duration-average">10h 12min</span></td>
                            <td><span id="energy-average">100</span> kWh</td>
                            <td><span id="co2-average">1.5</span> kg</td>
                            <td><span id="energy-rank-average">1</span></td>
                        </tr>
                        <tr>
                            <td>Last Month</td>
                            <td><span id="duration-lastMonth">0h 0min</span></td>
                            <td><span id="energy-lastMonth">0</span> kWh</td>
                            <td><span id="co2-lastMonth">0</span> kg</td>
                            <td><span id="energy-rank-lastMonth">-</span></td>
                        </tr>
                        <tr>
                            <td>This Month</td>
                            <td><span id="duration-thisMonth">0h 0min</span></td>
                            <td><span id="energy-thisMonth">0</span> kWh</td>
                            <td><span id="co2-thisMonth">0</span> kg</td>
                            <td><span id="energy-rank-thisMonth">-</span></td>
                        </tr>
                     </tbody>
                </table>

                <div></div>
                <button id="start-exercise-btn">Start to exercise</button><br>
                
                <div id="exercise-timer" style="display:none;">
                    <div>
                        <center>
                            <span id="exercise-duration-hour" class="em-tips-timer-minhour">0</span><small class="em-tips-timer-minhour">h </small>
                            <span id="exercise-duration-min" class="em-tips-timer-minhour">0</span><small class="em-tips-timer-minhour">m </small>
                            <span id="exercise-duration-sec" class="em-tips-timer-sec">0</span><small class="em-tips-timer-sec">s </small>
                        </center>
                    </div>
                    <div id="Exercise-equipment-info" style="margin-top:1em">
                        <ul data-role="listview">
                            <li>place: gym 001</li>
                            <li>equipment type: bike</li>
                        </ul>
                    </div>
                </div>

            <div id="exercise-achievement-thisTime" style="display:none;">
                <table data-role="table" data-mode="column" class="ui-responsive table-stroke">
                    <thead>
                        <tr>
                            <th>This exercise</th>
                            <th data-priority="1">Achievement</th>
                        </tr>
                    </thead>
                        <tbody>
                            <tr>
                                <td>Start time</td>
                                <td><span id="startTime-thisEx">2014-11-11 15:30</span></td>
                            </tr>
                            <tr>
                                <td>End time</td>
                                <td><span id="endTime-thisEx">2014-11-11 15:32</span></td>
                            </tr>
                            <tr>
                                <td>Duration</td>
                                <td>
                                    <span id="duration-hour-thisEx">0</span> <small>h</small>
                                    <span id="duration-min-thisEx">2</span> <small>min</small>
                                </td>
                            </tr>
                            <tr>
                                <td>Energy</td>
                                <td><span id="energy-thisTime">100</span> kWh</td>
                            </tr>
                            <tr>
                                <td>Peak Power</td>
                                <td><span id="peak-power-thisTime">450</span> W</td>
                            </tr>
                            <tr>
                                <td>Efficiency</td>
                                <td><span id="efficiency-thisTime">78</span> %</td>
                            </tr>
                            <tr>
                                <td>CO<small>2</small> reduced</td>
                                <td><span id="co2-reduced-thisTime">1.1</span> kg</td>
                            </tr>
                        </tbody>
                    </table>
                    <button id="share-this-exercise-btn">Share</button><br>
                </div>
                
            </div>
        </div>

        <div data-role="page" id="sign_up_page">
            <script type="text/javascript">

                function isUseridValidate(userid) {
                    return /^[a-zA-Z][a-zA-Z0-9_]{2,16}$/.test(userid);
                }

                function checkUserid(userid_, if_exist, otherwise, formatInvalid) {
                    // 先检查userid是否符合表达式要求
                    if (!isUseridValidate(userid_)) {
                        formatInvalid();
                    } else {
                        $.ajax({
                            url: "checkUserid",
                            type: "post",
                            data: {
                                userid: userid_
                            },
                            datatype: "json",
                            async: true,
                            crossDomain: true,
                            success: function(result) {
                                if (result["exist"]) {
                                    if_exist();
                                } else {
                                    otherwise();
                                }
                            }
                        }); 
                    }
                }

                function submitSignUpInfo(userid, password, mobile, address, userName, handleError) {
                    $.ajax({
                        url: "signup",
                        type: "post",
                        data: {
                            userid: userid,
                            password: password,
                            userName: userName,
                            mobile: mobile,
                            address: address
                        },
                        datatype: "json",
                        async: true,
                        crossDomain: true,
                    }).then(function(result) {
                        if (result.success) {
                            // 注册成功后直接登陆
                            loginSubmit(userid, password);
                        } else {
                            handleError(result.reason);
                        }
                    });
                }

                $(document).ready(function() {
                    $("#signup-submit").click(function() {
                        var userid = $("#signup-user-id").val();
                        var password = $("#signup-password").val();
                        var password_re = $("#signup-password-repeat").val();
                        var name = $("#signup-user-name").val();
                        var mobile = $("#signup-user-mobile").val();
                        var address = $("#signup-user-address").val();

                        var check_ok = true;

                        // check userid
                        if (!isUseridValidate(userid)) {
                            check_ok = false;
                            $("#signup-user-id-tip").text("User name can only contain a-z, A-Z, 0-9 and underline, and starts with letter");
                            $("#signup-user-id-tip").css("color", "red");
                            $("#signup-user-id-tip").slideDown();
                        }

                        // check password
                        if (password == "" || password_re == "") {
                            $("#signup-password-tip").text("please input password.");
                            $("#signup-password-tip").slideDown();
                            check_ok = false;
                        } else if (password != password_re) {
                            $("#signup-password-tip").text("passwords are not the same.");
                            $("#signup-password-tip").slideDown();
                            check_ok = false;
                        } else {
                            $("#signup-password-tip").slideUp();
                        }


                        if (userid == "") {
                            check_ok = false;
                        }

                        if (name == "") {
                            // 默认名字和id相同
                            name = userid;
                        }

                        if (check_ok) {
                            submitSignUpInfo(userid, password, name, mobile, address, function(reason) {
                                // handle the error reason
                                if (reason == 1) {
                                    $("#signup-result").text("user name exist, please change another.");
                                } else if (reason == 2) {
                                    $("#signup-result").text("some error occured, please contact the administrator.");
                                }
                            });
                        }
                    });
                    
                    $("#signup-user-id").blur(function() {
                        checkUserid($(this).val(),
                            function() {
                                $("#signup-user-id-tip").text("This user name has been used, please change another.");
                                $("#signup-user-id-tip").css("color", "red");
                                $("#signup-user-id-tip").slideDown();
                            },
                            function() {
                                $("#signup-user-id-tip").text("Ok! you can use it.");
                                $("#signup-user-id-tip").css("color", "green");
                                $("#signup-user-id-tip").slideDown();
                            },
                            function() {
                                $("#signup-user-id-tip").text("User name can only contain a-z, A-Z, 0-9 and underline, and starts with letter");
                                $("#signup-user-id-tip").css("color", "red");
                                $("#signup-user-id-tip").slideDown();
                            }
                        );
                    });

                    $("#signup-password-repeat").blur(function() {
                        if ($(this).val() != $("#signup-password").val()) {
                            $("#signup-password-tip").text("passwords are not the same.");
                            $("#signup-password-tip").slideDown();
                        } else {
                            $("#signup-password-tip").slideUp();
                        }
                    });
                });
            </script>
            <div data-role="header">
                <a href="#login" data-rel="back"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">Back</a>
                <h1>New user</h1>
                <a href="#" id="signup-submit"
                    class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all">Ok</a>
            </div>
            <div data-role="content">
                <form>
                    <input id="signup-user-id" type="text" data-clear-btn="true" placeholder="User name" />
                    <p id="signup-user-id-tip" style="display:none;" class="tips-text"></p>
                    <input id="signup-password" type="password" data-clear-btn="true" placeholder="Password" />
                    <input id="signup-password-repeat" type="password" data-clear-btn="true" placeholder="Password repeat" />
                    <p id="signup-password-tip" style="display:none;color:red;" class="tips-text"></p>
                    
                    <p style="margin-top:3em;background-color:#FFFACD;font-size:0.7em;color:gray;">
                        The fallowing information are only used for finding the personal password back if the password is missed. 
                        We guarantee that all the personal information are under highly confidential.
                    </p>
                    <input id="signup-user-name" type="text" data-clear-btn="true" placeholder="name or nick name" />
                    <input id="signup-user-mobile" type="text" data-clear-btn="true" placeholder="mobile phone number" />
                    <input id="signup-user-email" type="text" data-clear-btn="true" placeholder="e-mail" />
                    
                    <input id="signup-user-address" type="text" data-clear-btn="true" placeholder="the place you live in" />
                    <p id="signup-result" style="color:red;" class="tips-text"></p>
                </form>
            </div>
        </div>
     
    </body>

</html>

