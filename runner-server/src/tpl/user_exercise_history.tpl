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
	</head>

	<body>
		<div data-role="page" id="user_exercise_history">
            <script type="text/javascript">
                
                $(document).ready(function() {
                	var gUserid = window.localStorage.getItem("savedUserid");
                	$.ajax({
                        url: "getUserLast10History",
                        type: "post",
                        data: {
                            userid: gUserid
                        },
                        datatype: "json",
                        async: true,
                        success: function(result) {
                            if (result.lastIndex != 0) {
                                var recordStr = "";
                                var recordIndex = result.lastIndex;

                                // for..in statement in javascript are not the same like java
                                for (i in result.histories) {
                                    var startTime = new Date(result.histories[i].startTime.replace(/\-/g, "/"));
                                    var endTime = new Date(result.histories[i].endTime.replace(/\-/g, "/"));
                                    var durationTotalSecond = (endTime - startTime) / 1000;
                                    var durationSecond = durationTotalSecond % 60;
                                    var durationMinute = parseInt(durationTotalSecond / 60) % 60;
                                    var durationHour = parseInt(parseInt(durationTotalSecond / 60) / 60);

                                    recordStr += "\
                                                <tr id='user-record-" + recordIndex + "'>\
                                                    <td>" + startTime.toLocaleDateString() + "</td>\
                                                    <td data-priority='1'>" + durationHour + "h " + durationMinute + "m " + durationSecond + "s " + "</td>\
                                                    <td data-priority='1'>" + result.histories[i].energy + " kWh</td>\
                                                    <td data-priority='2'>122 kg</td>\
                                                    <td data-priority='3'>" + result.histories[i].peakPower + " W</td>\
                                                    <td data-priority='4'>" + result.histories[i].efficiency + " %</td>\
                                                </tr>";
                                    recordIndex--;
                                }
                                $("#history-table-body").html(recordStr);
                               
                                window.location.href = "#user_exercise_history";
                            } else {
                                alert("you don't have any exercise records.");
                            }
                        }
                    });
                });

            </script>
            <div data-role="header">
                <a href="#user_home_page" data-rel="back"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">Back</a>
                <h1>History</h1>
            </div>
            <div data-role="content">
                <div id="history-record-list">
                    
                </div>
                <table data-role="table" data-mode="columntoggle" class="ui-responsive table-stroke">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th data-priority="1">Duration</th>
                            <th data-priority="1">Energy</th>
                            <th data-priority="2">CO<small>2</small> reduced</th>
                            <th data-priority="3">Peak power</th>
                            <th data-priority="4">Efficiency</th>
                        </tr>
                    </thead>
                    <tbody id="history-table-body">
                        <tr>
                            <td>2014-11-23</td>
                            <td>1h 21min</td>
                            <td>1.2 kWh</td>
                            <td>122 kg</td>
                            <td>300 W</td>
                            <td>56 %</td>
                        </tr>
                        <tr>
                            <td>2014-11-23</td>
                            <td>1h 21min</td>
                            <td>1.2 kWh</td>
                            <td>122 kg</td>
                            <td>300 W</td>
                            <td>56 %</td>
                        </tr>
                     </tbody>
                </table>
                <p>
                    <center style="color:gray;font-size:0.8em;">
                        <span id="user-history-records-count">2</span> records
                    </center>
                </p>
            </div>
        </div>
    </body>

</html>