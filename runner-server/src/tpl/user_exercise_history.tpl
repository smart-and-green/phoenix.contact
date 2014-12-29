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
		<div data-role="page" id="user_exercise_history" date-ajax="false">
            <script type="text/javascript">
                var loadedRecord = {
                    earliestYear: 0,
                    earliestMonth: 0,
                    count: 0,
                    noMoreExRecord: false
                };

                function addUserMonthExRecord(userid, year, month) {
                    if (loadedRecord.noMoreExRecord == true) {
                        return;
                    } else {
                        loadedRecord.earliestYear = year;
                        loadedRecord.earliestMonth = month;
                    }

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
                            // save the status of loaded record
                            loadedRecord.noMoreExRecord = result.noMoreExRecord;

                            if (result.count > 0) {
                                loadedRecord.count += result.count;

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
                                var recentMonthLabel = year + "-" + (month + 1);
                                if (year == thisMonth.year && month == thisMonth.month){
                                    recentMonthLabel = "This month";  
                                } else if (year == lastMonth.year && month == lastMonth.month) {
                                    recentMonthLabel = "Last Month";
                                }

                                var divider = recordDividerTemplate
                                        .replace("[recent-month]", recentMonthLabel)
                                        .replace("[count]", result.count + "");
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
                                            .replace("[energy]", result.histories[index].energy)
                                            .replace("[duration]", durationHour + "h " + durationMinute + "m " + durationSecond + "s")
                                            .replace("[start-time]", dateStr + startTime.toLocaleTimeString());
                                }
                                $("#user-exercise-record-list").append(divider + record);

                                // add this statement to refresh the list after loaded.
                                $("ul").listview("refresh");

                                // remove the no ex record notification
                                $("#no-record-notification").html("");
                            } else if (loadedRecord.noMoreExRecord == false) {
                                month--;
                                if (month < 0) {
                                    month = 11;
                                    year--;
                                }
                                addUserMonthExRecord(userid, year, month);
                            }
                        },
                        error: function(e) {
                            alert("no response from server");
                        }
                    });
                }

                
                $(document).ready(function() {

                    // 先清除历史记录列表中原有的数据，重新从服务器加载
                    $("#user-exercise-record-list").html(""); 
                    loadedRecord.count = 0;
                    
                    // when enter this page, the following method should be called to init the listview
                    $("ul").listview();
                    
                    // 进入这个页面的时候自动加载这个月的历史记录
                    // 如果这个月没有记录，会自动加载上个月的，以此类推
                    // 如果这个月没有记录，会自动加载上个月的，以此类推
                    // loadedRecord对象中会保存最久以前所加载记录的年份和月份，即列表最下面的记录的月份
                    var userid = window.localStorage.getItem("savedUserid");
                    var thisYear = new Date().getFullYear();
                    var thisMonth = new Date().getMonth();
                    addUserMonthExRecord(userid, thisYear, thisMonth); 
                    $("#add-more-btn").text("touch to add more");

                    $("#add-more-btn").click(function() {
                        if (loadedRecord.noMoreExRecord == true) {
                            $(this).text("no more exercise record");
                        } else {
                            $(this).text("touch to add more");
                            // there are still some record unloaded
                            loadedRecord.earliestMonth--;
                            if (loadedRecord.earliestMonth < 0) {
                                loadedRecord.earliestMonth = 11;
                                loadedRecord.earliestYear--;
                            }
                            addUserMonthExRecord(userid, loadedRecord.earliestYear, loadedRecord.earliestMonth);
                        }
                    });
                });
                
            </script>
            <div data-role="header">
                <a href="/index#user_home_page" data-rel="back"
                    class="ui-btn-left ui-btn ui-btn-inline ui-mini ui-corner-all">Back</a>
                <h1>History</h1>
            </div>
            <div data-role="content">
                <div id="no-record-notification" style="color:gray;text-align:center;">
                    You don't have any exercise record. 
                    <button>
                        <h2>Let's run!</h2>
                    </button>
                </div>
                
                <div id="user-exercise-history-field">
                    <ul id="user-exercise-record-list" data-role="listview" data-inset="true">

                    </ul>
                    <div id="add-more-btn" style="padding:1em;color:gray;text-align:center;">
                    </div>
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
