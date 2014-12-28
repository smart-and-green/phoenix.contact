<!DOCTYPE html>
<html>
    <head>
        <title>runner</title>
        <meta charset="utf-8" />
        <link rel="stylesheet" type="text/css" href="css/jquery.mobile-1.4.5.min.css" />
        <link rel="stylesheet" type="text/css" href="css/runner.css" />
        <script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
        <script type="text/javascript" src="js/jquery.mobile-1.4.5.min.js"></script>
        
        <script type="text/javascript" src="js/cordova.js"></script>

        <script type="text/javascript" src="js/api.camera.js"></script>
        <script type="text/javascript" charset="utf-8" src="js/api.myPlugin.js"></script>
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
                        success: function(result) {
                            if (result["success"] == true) {
                                window.location.href = "#user_home_page";

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

                                // 等待服务器数据接口更新
                                //$("#duration-lastMonth").text(userData.lastMonthSummary.duration);
                                //$("#energy-lastMonth").text(userData.lastMonthSummary.energy);
                                //$("#co2-lastMonth").text(userData.lastMonthSummary.energy * 10);
                                //$("#energy-rank-lastMonth").text(userData.lastMonthSummary.globalRank);

                                //$("#duration-thisMonth").text(userData.thisMonthSummary.duration);
                                //$("#energy-thisMonth").text(userData.thisMonthSummary.energy);
                                //$("#co2-thisMonth").text(userData.thisMonthSummary.energy * 10);
                                //$("#energy-rank-thisMonth").text(userData.thisMonthSummary.globalRank);
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

        <div data-role="page" id="user_home_page">
            <script type="text/javascript">
                
                var IntvId;
                var StartSecStamp = 0;
		var EndSecStamp = 0;
                var EquipmentId = "";

                function updateDurationDisp() {
                    var myDate = new Date();
                    var currentMillis = myDate.getTime();
                    var currentSecCount = currentMillis / 1000 - StartSecStamp;
                    var currentMinCount = currentSecCount / 60;
                    $("#exercise-duration-sec").text(parseInt(currentSecCount % 60));
                    $("#exercise-duration-hour").text(parseInt(currentMinCount / 60));
                    $("#exercise-duration-min").text(parseInt(currentMinCount % 60));
                    $("#duration-displayer").fadeIn();
                }

                // 调用了此回调函数表示nfc读取成功
                // 处理解码后的卡信息，从中读取运动设备信息
                // 记录运动设备信息和运动量信息，并显示
                // 同时维护按钮内容的显示
                function startEx_startTimeInfoProc(code) {
                    console.log(code);
                    alert(code);

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
                    alert(code);

                    // 如果qrcode读取成功，处理完信息后将按钮转变成停止功能
                    $("#start-exercise-btn").text("Start to exercise");

                    // 停止计时
                    window.clearInterval(IntvId); 
                    var myDate = new Date();
                    var currentMillis = myDate.getTime();
                    EndSecStamp = currentMillis / 1000;

                    // 将解码的code打包到exerciseData
                    var startTime = new Date(StartSecStamp * 1000);
                    var endTime = new Date(EndSecStamp * 1000);
                    var exerciseData = {
                        startTime: startTime.toLocaleDateString() + " " + startTime.toLocaleTimeString(),
                        endTime: endTime.toLocaleDateString() + " " + endTime.toLocaleTimeString(),
                        energy: 0.12,
                        peakPower: 450.1,
                        efficiency: 0.78,
                        peakCurrent: 12.1,
                        peakVoltage: 45.7,
                        equipmentid: EquipmentId
                    };

                    var userid = window.localStorage.getItem("savedUserid");
                    uploadExRecord(userid, exerciseData);

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

                function captureAndDecode(fnCallback) {
                    // navigator.camera.getPicture(function(image) {
                    //     qrcode.callback = fnCallback; 
                    //     qrcode.decode("data:image/jpeg;base64," + image);
                    // }, function(e) {
                    //     console.log("camera error because: " + e);
                    // }, { 
                    //     quality: 25,
                    //     destinationType: destinationType.DATA_URL,
                    //     targetWidth: 640,
                    //     targetHeight: 480
                    // }); 
                    var mifareDefaultKey = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff];
                    var success = function(data) {  
                        alert("card id:\n" + data.cardId);  
                        var sector1str = "";
                        for (var i = 0; i < 16 * 4; ++i) {
                            sector1str += data.cardData[i].toString(16);
                        }
                        alert("block 1:\n" + sector1str);
			fnCallback("feed back data");     
                    };  
                    var error = function(e) {  
                        alert(e.reason);  
                    };  
                    window.plugins.nfc.read(success, error, mifareDefaultKey);
                    
                }

                function signOut() {
                    // 登出的时候自动清除保存的帐号和密码
                    window.localStorage.setItem("savedUserid", null);
                    window.localStorage.setItem("savedUserid", null);
                    window.localStorage.setItem("savedPassword", null);
                    window.localStorage.setItem("savedPassword", null);
                }


                function uploadExRecord(userid, exerciseData) {
                    $.ajax({
                        url: "uploadExRecord",
                        type: "post",
                        data: {
                            userid: userid,
                            exData: exerciseData
                        },
                        datatype: "json",
                        async: true,
                        success: function(result) {
                            if (result["success"]) {
                                alert("upload ok!");
                            } else {
                                alert("upload fail");
                            }
                        }
                    });
                }

        		function getUserMonthExRecord(userid, year, month) {
                    $.ajax({
			            url: "getUserMonthExRecord",
                        type: "post",
			            data: { 
			                userid: userid,
			                year: year,
                            month: month
			            },
			            datatype: "json",
			            async: true,
			            success: function(result) {
			                if (result.count != 0) {
				                var recordDividerTemplate = "\
                        		    <li data-role='list-divider'>\
                            			<span>[recent-month]</span>\
			    			            <span class='ui-li-count'>[count]</span>\
                        		    </li>";
				                var recordTemplate = "\
                        		    <li>\
                              		    <a href='[link]'>\
                               			    <h2>[exercise-type]</h2>\
                                		    <p>[start-time] <strong>duration:</strong> [duration]</p>\
	                        	  	        <p class='ui-li-aside'><strong>[energy]</strong>kJ</p>\
                            		    </a>\
                        		    </li>";
                                var divider = recordDividerTemplate
                                        .replace("[recent-month]", year + "-" + month)
                                        .replace("[count]", result.count + "");
                                var record = "";
                                for (index = 0; result.histories[index] != null; ++index) {
                                    var startTime = new Date(result.histories[index].startTime.replace(/\-/g, "/"));
                                    var endTime = new Date(result.histories[index].endTime.replace(/\-/g, "/"));
                                    var durationTotalSecond = (endTime - startTime) / 1000;
                                    var durationSecond = durationTotalSecond % 60;
                                    var durationMinute = parseInt(durationTotalSecond / 60) % 60;
                                    var durationHour = parseInt(parseInt(durationTotalSecond / 60) / 60);
			
                                    var dateStr = "";
                                    var dayOfMonth = startTime.getDate();
                                    if (dayOfMonth == 1 || dayOfMonth == 21 || dayOfMonth == 31) {
                                       dateStr = dayOfMonth + "st ";
                                    } else if (dayOfMonth == 2 || dayOfMonth == 22) {
                                       dateStr = dayOfMonth + "nd ";
                                    } else if (dayOfMonth == 3 || dayOfMonth == 23) {
                                       dateStr = dayOfMonth + "rd ";
                                    } else {
                                       dateStr = dayOfMonth + "th ";
                                    }
				                    record += recordTemplate
                                            .replace("[link]", "#")
                                            .replace("[exercise-type]", "bike")
                                            .replace("[energy]", result.histories[index].energ)
                                            .replace("[duration]", durationHour + "h " + durationMinute + "m " + durationSecond + "s")
                                            .replace("[start-time]", dateStr + startTime.toLocaleTimeString());
                                    recordIndex--;
                                    $("#user-exercise-record-list").append(divider + record);
                                }
                            }    
			            }
		            });
		        }

                function getUserLast10ExHistory(userid) {
                    $.ajax({
                        url: "getUserLast10History",
                        type: "post",
                        data: {
                            userid: userid
                        },
                        datatype: "json",
                        async: true,
                        success: function(result) {
                            if (result.lastIndex != 0) {
				                var recordDividerTemplate = "\
                        		    <li data-role='list-divider'>\
                            			<span>[recent-month]</span>\
			    			            <span class='ui-li-count'>[count]</span>\
                        		    </li>";
				                var recordTemplate = "\
                        		    <li>\
                              		    <a href='[link]'>\
                               			    <h2>[exercise-type]</h2>\
                                		    <p>[start-time] <strong>duration:</strong> [duration]</p>\
	                        	  	        <p class='ui-li-aside'><strong>[energy]</strong></p>\
                            		    </a>\
                        		    </li>";
                                var recordIndex = result.lastIndex;
				                var thisYear = new Date().getFullYear();
				                var thisMonth = new Date().getMonth();

				                var index = 0;
                                for (; result.histories[index] != null; index++) {
                                    var startTime = new Date(result.histories[index].startTime.replace(/\-/g, "/"));
                                    var endTime = new Date(result.histories[index].endTime.replace(/\-/g, "/"));
                                    var durationTotalSecond = (endTime - startTime) / 1000;
                                    var durationSecond = durationTotalSecond % 60;
                                    var durationMinute = parseInt(durationTotalSecond / 60) % 60;
                                    var durationHour = parseInt(parseInt(durationTotalSecond / 60) / 60);
				
				                    var divider = recordDividerTemplate
                                            .replace("[recent-month]", thisYear + "-" + thisMonth)
                                            .replace("[count]", "1");
				                    var record = recordTemplate
                                            .replace("[link]", "#")
                                            .replace("[exercise-type]", "bike")
                                            .replace("[energy]", result.histories[index].energy + " kJ")
                                            .replace("[duration]", durationHour + "h " + durationMinute + "m " + durationSecond + "s")
                                            .replace("[start-time]", startTime.getDate() + "th " +  startTime.toLocaleTimeString());
                                    recordIndex--;
                                    $("#user-exercise-record-list").append(divider + record);
                                }
                                $("#user-history-records-count").text(result.lastIndex);

                                window.location.href = "#user_exercise_history";
                            } else {
                                alert("you don't have any exercise records.");
                            }
                        },
                        error: function() {
                           alert("loading history error!");
                        }
                    });
                }

                
                $(document).ready(function() {
                    $("#signOutBtn").click(signOut);
                    $("#start-exercise-btn").click(function() {
                        alert($(this).text());
                        if ($(this).text().indexOf("Start") >= 0) {
                            captureAndDecode(startEx_startTimeInfoProc);
                        } else if ($(this).text().indexOf("Stop") >= 0) {
                            captureAndDecode(stopEx_endTimeInfoProc);
                        }

                        // 刚按开始运动或者结束运动后，按钮会禁用1.5s
                        // 避免信息尚未读取或处理成功又进行了第二次读取或处理
                        $(this).attr("disabled", true);
                        window.setTimeout(function() {
                            $("#start-exercise-btn").removeAttr("disabled");
                        }, 1500);
                    });

                    $("#user-ex-history-btn").click(function() {
                        window.location.href = "#user_exercise_history";
                    });
                });

            </script>
            <div data-role="header">
                <a href="#login" id="signOutBtn"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">Sign out</a>
                <h1 id="userNameHead">[name]</h1>
                <a href="#" id="user-ex-history-btn"
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
                            <td><span id="duration-lastMonth">10h 12min</span></td>
                            <td><span id="energy-lastMonth">100</span> kWh</td>
                            <td><span id="co2-lastMonth">1.5</span> kg</td>
                            <td><span id="energy-rank-lastMonth">1</span></td>
                        </tr>
                        <tr>
                            <td>This Month</td>
                            <td><span id="duration-thisMonth">10h 12min</span></td>
                            <td><span id="energy-thisMonth">100</span> kWh</td>
                            <td><span id="co2-thisMonth">1.5</span> kg</td>
                            <td><span id="energy-rank-thisMonth">1</span></td>
                        </tr>
                     </tbody>
                </table>

                <button id="start-exercise-btn">Start to exercise</button><br>
                
                <div id="exercise-timer" style="display:none;">
		    <div id="duration-displayer">
                        <center>
                            <span id="exercise-duration-hour" class="em-tips-timer-minhour">0</span><small class="em-tips-timer-minhour">h </small>
                            <span id="exercise-duration-min" class="em-tips-timer-minhour">0</span><small class="em-tips-timer-minhour">m </small>
                            <span id="exercise-duration-sec" class="em-tips-timer-sec">0</span><small class="em-tips-timer-sec">s </small>
                        </center>
                    </div>
                    <div id="Exercise-equipment-nfo">
                        <p>Exercise equipment information:</p>
                        <ul>
                            <li>Exercise place: gym 001</li>
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

                function submitSignUpInfo(userid, password, userName, handleError) {
                    $.ajax({
                        url: "signup",
                        type: "post",
                        data: {
                            userid: userid,
                            password: password,
                            userName: userName
                        },
                        datatype: "json",
                        async: true,
                        success: function(result) {
                            if (result["success"] == true) {
                                // 注册成功后直接登陆
                                loginSubmit(userid, password);
                            } else {
                                handleError(result["reason"]);
                            }
                        }
                    });
                }

                $(document).ready(function() {
                    $("#signup-submit").click(function() {
                        var userid = $("#signup-user-id").val();
                        var password = $("#signup-password").val();
                        var password_re = $("#signup-password-repeat").val();
                        var name = $("#signup-user-name").val();

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
                            submitSignUpInfo(userid, password, name, function(reason) {
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
                    <input id="signup-user-name" type="text" data-clear-btn="true" placeholder="name or nick name" />
                    <p id="signup-result" style="color:red;" class="tips-text"></p>
                </form>
            </div>
        </div>

        <div data-role="page" id="user_exercise_history">
            <script type="text/javascript">
                var loadedRecord = {
                    earliestYear: 0,
                    earliestMonth: 0
                };
        		function getUserMonthExRecord(userid, year, month) {
                    $.ajax({
			            url: "getUserMonthExRecord",
                        type: "post",
			            data: { 
			                userid: userid,
			                year: year,
                            month: month
			            },
			            datatype: "json",
			            async: true,
			            success: function(result) {
			                if (result.count != 0) {
				                var recordDividerTemplate = "\
                        		    <li data-role='list-divider'>\
                            			<span>[recent-month]</span>\
			    			            <span class='ui-li-count'>[count]</span>\
                        		    </li>";
				                var recordTemplate = "\
                        		    <li>\
                              		    <a href='[link]'>\
                               			    <h2>[exercise-type]</h2>\
                                		    <p>[start-time] <strong>duration:</strong> [duration]</p>\
	                        	  	        <p class='ui-li-aside'><strong>[energy]</strong>kJ</p>\
                            		    </a>\
                        		    </li>";

                                // 将最近两个月的标签用this month和last month表示 
                                var thisMonth = {
                                    year: new Date().getFullYear(),
                                    month: new Date().getMonth()
                                };
                                var lastMonth = {
                                    year: thisMonth.year,
                                    month: thisMonth.month - 1
                                };
                                if (lastMonth.month < 0) {
                                    lastMonth.month = 11;
                                    lastMonth.year--;
                                }
                                var recentMonthLabel = year + "-" + month;
                                if (year == thisMonth.year && month == thisMonth.month){
                                    recentMonthLabel = "This month";  
                                } else if (year == lastMonth.year && month == lastMonth.month) {
                                    recentMonthLabel = "Last Month";
                                }

                                var divider = recordDividerTemplate
                                        .replace("[recent-month]", year + "-" + month)
                                        .replace("[count]", recentMonthLabel);
                                var record = "";
                                for (var index = 0; result.histories[index] != null; ++index) {
                                    var startTime = new Date(result.histories[index].startTime.replace(/\-/g, "/"));
                                    var endTime = new Date(result.histories[index].endTime.replace(/\-/g, "/"));
                                    var durationTotalSecond = (endTime - startTime) / 1000;
                                    var durationSecond = durationTotalSecond % 60;
                                    var durationMinute = parseInt(durationTotalSecond / 60) % 60;
                                    var durationHour = parseInt(parseInt(durationTotalSecond / 60) / 60);
			
                                    var dateStr = "";
                                    var dayOfMonth = startTime.getDate();
                                    if (dayOfMonth == 1 || dayOfMonth == 21 || dayOfMonth == 31) {
                                       dateStr = dayOfMonth + "st ";
                                    } else if (dayOfMonth == 2 || dayOfMonth == 22) {
                                       dateStr = dayOfMonth + "nd ";
                                    } else if (dayOfMonth == 3 || dayOfMonth == 23) {
                                       dateStr = dayOfMonth + "rd ";
                                    } else {
                                       dateStr = dayOfMonth + "th ";
                                    }
				                    record += recordTemplate
                                            .replace("[link]", "#")
                                            .replace("[exercise-type]", "bike")
                                            .replace("[energy]", result.histories[index].energ)
                                            .replace("[duration]", durationHour + "h " + durationMinute + "m " + durationSecond + "s")
                                            .replace("[start-time]", dateStr + startTime.toLocaleTimeString());
                                    recordIndex--;
                                    $("#user-exercise-record-list").append(divider + record);
                                }
                            } else {
                                month--;
                                if (month < 0) {
                                    month = 11;
                                    year--;
                                }
                                loadedRecord.earliestYear = year;
                                loadedRecord.earliestMonth = month;  
                                getUserMonthExRecord(userid, year, month);
                            }
			            },
                        error: function(e) {
                            alert("no response from server");
                        }
		            });
		        }

                $(document).on("pagebeforeshow", "#user_exercise_history", function() {
                    // 先清除历史记录列表中原有的数据，重新从服务器加载
                    $("#user-exercise-record-list").html(""); 
                    
                    // 进入这个页面的时候自动加载这个月的历史记录
                    // 如果这个月没有记录，会自动加载上个月的，以此类推
                    // loadedRecord对象中会保存最久以前所加载记录的年份和月份，即列表最下面的记录的月份
                    var userid = window.localStorage.getItem("savedUserid");
                    alert(userid);
                    var thisYear = new Date().getFullYear();
                    var thisMonth = new Date().getMonth();
                    getUserMonthExRecord(userid, thisYear, thisMonth); 

                });

            </script>
            <div data-role="header">
                <a href="#user_home_page" data-rel="back"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">Back</a>
                <h1>History</h1>
            </div>
            <div data-role="content">
                <div id="user-exercise-history-field">
                    <ul id="user-exercise-record-list" data-role="listview" data-inset="true">

                        <li data-role="list-divider">
                            <span>[yyyy/MM]</span>
                            <span class="ui-li-count">[count]</span>
                        </li>
                        <li>
                            <a href="#">
                                <h2>[running]</h2>
                                <p>2014/11/23 12:50 duration: 1h 30m</p>
	                        <p class="ui-li-aside">energy:<strong>[energy]</strong></p>
                            </a>
                        </li>
                        <li>
                            <a href="#">
                                <h2>[running]</h2>
                                <p>2014/11/23 12:50 duration: 1h 30m</p>
	                        <p class="ui-li-aside">energy:<strong>[energy]</strong></p>
                            </a>
                        </li>

                        <li data-role="list-divider">
                            <span >[yyyy/MM]</span>
                            <span class="ui-li-count">[count]</span>
                        </li>
                        <li>
                            <a href="#">
                                <h2>[running]</h2>
                                <p>2014/11/23 12:50 duration: 1h 30m</p>
	                        <p class="ui-li-aside">energy:<strong>[energy]</strong></p>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>

        <div data-role="page" id="user_exercise_history_detail">
            <div data-role="header">
                <a href="#user_home_page" data-rel="back"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">Back</a>
                <h1>[Data(e.g. 2014-11-24)]</h1>
            </div>
            <div data-role="content">
                 
            </div>
        </div>
    </body>

</html>
