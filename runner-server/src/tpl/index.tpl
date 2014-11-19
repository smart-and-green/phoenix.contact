<!DOCTYPE html>
<html>
    <head>
        <title>login</title>
        <meta charset="utf-8" />
        <link rel="stylesheet" href="css/jquery.mobile-1.4.5.min.css" />
        <script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
        <script type="text/javascript" src="js/jquery.mobile-1.4.5.min.js"></script>
        <script type="text/javascript" src="js/cordova.js"></script>

        <script type="text/javascript" src="js/qr/src/grid.js"></script>
        <script type="text/javascript" src="js/qr/src/version.js"></script>
        <script type="text/javascript" src="js/qr/src/detector.js"></script>
        <script type="text/javascript" src="js/qr/src/formatinf.js"></script>
        <script type="text/javascript" src="js/qr/src/errorlevel.js"></script>
        <script type="text/javascript" src="js/qr/src/bitmat.js"></script>
        <script type="text/javascript" src="js/qr/src/datablock.js"></script>
        <script type="text/javascript" src="js/qr/src/bmparser.js"></script>
        <script type="text/javascript" src="js/qr/src/datamask.js"></script>
        <script type="text/javascript" src="js/qr/src/rsdecoder.js"></script>
        <script type="text/javascript" src="js/qr/src/gf256poly.js"></script>
        <script type="text/javascript" src="js/qr/src/gf256.js"></script>
        <script type="text/javascript" src="js/qr/src/decoder.js"></script>
        <script type="text/javascript" src="js/qr/src/qrcode.js"></script>
        <script type="text/javascript" src="js/qr/src/findpat.js"></script>
        <script type="text/javascript" src="js/qr/src/alignpat.js"></script>
        <script type="text/javascript" src="js/qr/src/databr.js"></script>

        <script type="text/javascript" src="js/api.camera.js"></script>

	</head>

    <body>
    	<div data-role="page" id="login">
            <script type="text/javascript">
                $(document).ready(function(){
                    $("#loginSubmit").click(function(){
                        
                        // clear the login result
                        $("#login-result").text("");
                        
                        var userid = $("#login-user-name").val();
                        var password = $("#login-password").val();
                        
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
                                } else {
                                    $("#login-result").text("user name or password error.");
                                }
                            },
                            error: function(XMLHttpRequest, info, e){
                                alert("error: " + XMLHttpRequest.readyState);
                            }
                        });
                    });
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
                    <a href="#sign_up_page" class="ui-btn ui-corner-all">Signup</a>
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
                function read(a) {
                    $("#qrContent").text(a);
                }

                function captureAndDecode() {
                    navigator.camera.getPicture(function(image) {
                        qrcode.callback = read; 
                        qrcode.decode("data:image/jpeg;base64," + image);
                        $("#qrContent").text("decoding");
                    }, function(e) {
                        console.log("camera error: " + e);
                    }, { 
                        quality: 20,
                        destinationType: destinationType.DATA_URL,
                        targetWidth: 640,
                        targetHeight: 480
                    }); 
                }
            </script>
            <div data-role="header">
                <a href="#login"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">Sign out</a>
                <h1 id="userNameHead">adolli</h1>
                <a href="#"
                    class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all">Setting</a>
            </div>
            <div data-role="content">
                <table data-role="table" id="table-column-toggle" data-mode="columntoggle" class="ui-responsive table-stroke">
                    <thead>
                        <tr>
                            <th>Item</th>
                            <th data-priority="1">Value</th>
                            <th data-priority="2">Global rank</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Total energy</td>
                            <td>100 kWh</td>
                            <td>1</td>
                        </tr>
                        <tr>
                            <td>Fitness time</td>
                            <td>10h 12min</td>
                            <td>1</td>
                        </tr>
                        <tr>
                            <td>CO2 reduced</td>
                            <td>1.2 kg</td>
                            <td>1</td>
                        </tr>
                        <tr>
                            <td>---</td>
                            <td>---</td>
                            <td>1</td>
                        </tr>
                     </tbody>
                </table>

                <button onclick="captureAndDecode();">Start to exercise</button><br>
                <p id="qrContent"></p>
                
            </div>
        </div>

        <div data-role="page" id="sign_up_page">
            <script type="text/javascript">

                var useridExist = false;

                function checkUserid(userid_, if_exist, otherwise) {
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
                                window.location.href = "#login";
                            } else {
                                $("#signup-result").text("signup error.");
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

                        if (password != password_re && password != "") {
                            $("#signup-result").text("passwords are not the same");
                            $("#signup-result").show();
                            check_ok = false;
                        } else {
                            $("#signup-result").hide();
                        }


                        if (userid == "") {
                            check_ok = false;
                        }

                        if (name == "") {
                            name = "new user";
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
                                $("#signup-user-id-tip").text("this user name has been used, please change another.");
                                $("#signup-user-id-tip").css("color", "red");
                                $("#signup-user-id-tip").slideDown();
                            },
                            function() {
                                $("#signup-user-id-tip").text("ok! you can use it.");
                                $("#signup-user-id-tip").css("color", "green");
                                $("#signup-user-id-tip").slideDown();
                            }
                        );
                    });
                });
            </script>
            <div data-role="header">
                <a href="index.html" data-rel="back"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">Back</a>
                <h1>New user</h1>
                <a href="#" id="signup-submit"
                    class="ui-btn-right ui-btn ui-btn-inline ui-mini ui-corner-all">Ok</a>
            </div>
            <div data-role="content">
                <form>
                    <input id="signup-user-id" type="text" data-clear-btn="true" placeholder="User name" />
                    <p id="signup-user-id-tip" style="display:none;"></p>
                    <input id="signup-password" type="password" data-clear-btn="true" placeholder="Password" />
                    <input id="signup-password-repeat" type="password" data-clear-btn="true" placeholder="Password repeat" />
                    <input id="signup-user-name" type="text" data-clear-btn="true" placeholder="name or nick name" />
                    <p id="signup-result" style="color:red;"></p>
                </form>
            </div>
        </div>

    </body>

</html>
