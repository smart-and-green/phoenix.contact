<!DOCTYPE html>
<html>	
	<head>
        <title>runner</title>
        <meta charset="utf-8" />
        <link rel="stylesheet" type="text/css" href="css/runner-theme-w.min.css" />
        <link rel="stylesheet" type="text/css" href="css/jquery.mobile.icons.min.css" />
        <link rel="stylesheet" type="text/css" href="css/jquery.mobile.structure-1.4.5.css" />
        <link rel="stylesheet" type="text/css" href="css/runner.css" />
        <script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
        <script type="text/javascript" src="js/jquery.mobile-1.4.5.min.js"></script>   
        <script type="text/javascript" src="js/cordova.js"></script>
        <script type="text/javascript" src="js/runner-global.js"></script>
	</head>

	<body>
		<div data-role="page">
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
                        url: SERVER_ADDRESS + "/getUserMonthExRecord",
                        type: "post",
                        data: { 
                            userid: userid,
                            year: year,
                            month: month
                        },
                        datatype: "json",
                        async: true,
                        crossDomain: true,
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
                                            <h2 id='exercise-type-'>[exercise type]</h2>\
                                            <span style='display:none;' id='date-'>[date]</span>\
                                            <p>\
                                                <span id='datestr-'> [datestr] </span>\
                                                <span id='start-time-'>[start time]</span> \
                                                <span style='display:none;' id='end-time-'>[end time]</span>\
                                                <strong>duration: </strong><span id='duration-'>[duration]</span>\
                                            </p>\
                                            <p class='ui-li-aside'><strong><span id='erengy-'>[energy]</span></strong>kJ</p>\
                                            <span style='display:none;' id='efficiency-'>[efficiency]</span>\
                                            <span style='display:none;' id='peak-power-'>[peak power]</span>\
                                            <span style='display:none;' id='peak-voltage-'>[peak voltage]</span>\
                                            <span style='display:none;' id='peak-current-'>[peak current]</span>\
                                            <span style='display:none;' id='ex-equipment-id-'>[ex equipment id]</span>\
                                            <span style='display:none;' id='ex-equipment-name-'>[ex equipment name]</span>\
                                            <span style='display:none;' id='ex-equipment-fitnessCenterName-'>[ex equipment fitnessCenterName]</span>\
                                            <span style='display:none;' id='ex-equipment-fitnessCenterAddress-'>[ex equipment fitnessCenterAddress]</span>\
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
                                $("#user-exercise-record-list").append(divider);
                                
                                var recordIndex = result.count;
                                for (var index = 0; result.histories[index] != null; ++index) {
                                    recordIndex--;
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
                                    var record = recordTemplate
                                            .replace("[link]", "#" + recordIndex)
                                            .replace("[exercise type]", result.histories[index].exEquipment.type)
                                            .replace("[energy]", result.histories[index].energy)
                                            .replace("[duration]", durationHour + "h " + durationMinute + "m " + durationSecond + "s")
                                            .replace("[datestr]", dateStr)
                                            .replace("[date]", startTime.toLocaleDateString())
                                            .replace("[start time]", startTime.toLocaleTimeString())
                                            .replace("[end time]", endTime.toLocaleTimeString())
                                            .replace("[efficiency]", result.histories[index].efficiency)
                                            .replace("[peak power]", result.histories[index].peakPower)
                                            .replace("[peak voltage]", result.histories[index].peakVoltage)
                                            .replace("[peak current]", result.histories[index].peakCurrent)
                                            .replace("[ex equipment id]", result.histories[index].exEquipment.equipment_id)
                                            .replace("[ex equipment name]", result.histories[index].exEquipment.name)
                                            .replace("[ex equipment fitnessCenterName]", result.histories[index].exEquipment.fitnessCenterName)
                                            .replace("[ex equipment fitnessCenterAddress]", result.histories[index].exEquipment.fitnessCenterAddress)
                                            ;
                                    var recordElement = $(record);
                                    recordElement.click(function() { 
                                        var efficiency = $(this).find("#efficiency-").text();
                                        var peakPower = $(this).find("#peak-power-").text();
                                        var peakVoltage = $(this).find("#peak-voltage-").text();
                                        var peakCurrent = $(this).find("#peak-current-").text();
                                        var date = $(this).find("#date-").text();
                                        var startTime = $(this).find("#start-time-").text();
                                        var endTime = $(this).find("#end-time-").text();
                                        var duration = $(this).find("#duration-").text();
                                        var energy = $(this).find("#erengy-").text();
                                        var co2reduced = (parseFloat(energy) * CO2_REDUCTION_GRAM_PER_1kWh).toFixed(3);
                                        var exEquipmentId = $(this).find("#ex-equipment-id-").text();
                                        var exEquipmentName = $(this).find("#ex-equipment-name-").text();
                                        var exEquipmentType= $(this).find("#exercise-type-").text();
                                        var fitnessCenterName = $(this).find("#ex-equipment-fitnessCenterName-").text();
                                        var fitnessCenterAddress= $(this).find("#ex-equipment-fitnessCenterAddress-").text();

                                        $("#record-detail-title").text(date);
                                        $("#record-detail-efficiency").text(efficiency);
                                        $("#record-detail-peak-power").text(peakPower);
                                        $("#record-detail-peak-voltage").text(peakVoltage);
                                        $("#record-detail-peak-current").text(peakCurrent);
                                        $("#record-detail-startTime").text(startTime);
                                        $("#record-detail-endTime").text(endTime);
                                        $("#record-detail-duration").text(duration);
                                        $("#record-detail-energy").text(energy);
                                        $("#record-detail-co2reduced").text(co2reduced);

                                        $("#record-detail-fitness-equipment-type").text(exEquipmentType);
                                        $("#record-detail-fitness-equipment-name").text(exEquipmentName);
                                        $("#record-detail-fitness-equipment-id").text(exEquipmentId);
                                        $("#record-detail-fitness-center-name").text(fitnessCenterName);
                                        $("#record-detail-fitness-center-addr").text(fitnessCenterAddress);

                                        $.mobile.changePage("user_exercise_history#detail_page", "slideUp");
                                    });
                                    var newAppended = $("#user-exercise-record-list").append(recordElement);
                                }

                                // add this statement to refresh the list after loaded.
                                $("ul").listview("refresh");

                                // remove the no ex record notification
                                $("#first-enter-loading-notification").slideUp();
                                $("#add-more-btn").fadeIn();
                                $("#record-list-tips").fadeIn();
                            
                                // update the tips
                                if (loadedRecord.noMoreExRecord) {
                                    $("#add-more-btn").text("no more exercise record");
                                } else {
                                    $("#add-more-btn").text("touch to add more");
                                }
                            } else if (loadedRecord.noMoreExRecord == false) {
                                month--;
                                if (month < 0) {
                                    month = 11;
                                    year--;
                                }
                                addUserMonthExRecord(userid, year, month);
                            } else {
                                $("#add-more-btn").text("no more exercise record");
                                if (loadedRecord.count == 0) {
                                    $("#no-record-notification").fadeIn();
                                    $("#first-enter-loading-notification").fadeOut();
                                }
                            }
                        },
                        error: function(e) {
                            alert("you has disconnected with the server!");
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

                    $("#add-more-btn").click(function() {
                        if (!loadedRecord.noMoreExRecord) {
                            $(this).text("loading...");
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
            <div data-role="header" data-position="fixed" data-tap-toggle="false">
                <div style="margin:0.35em;" class="logo-back logo-300px" onclick="window.history.back();" ></div>
                <h1>History</h1>
            </div>
            <div data-role="content">
                <div id="first-enter-loading-notification" style="color:gray;text-align:center;">
                    Loading...
                </div>

                <div id="no-record-notification" style="display:none;color:gray;text-align:center;">
                    <button>
                        <span>You don't have any exercise record.</span>
                        <h2>Let's run!</h2>
                    </button>
                </div>
                
                <div id="user-exercise-history-field" style="margin-top:1em;">
                    <p id="record-list-tips" style="margin-bottom:2em;display:none;color:gray;font-size:0.7em;">
                        The exercise records are listed fallowing. You can press to view the detail information of each record.
                    </p>
                    <ul id="user-exercise-record-list" data-role="listview" data-inset="false">
                    </ul>
                    <div id="add-more-btn" style="display:none;padding:3em;color:gray;text-align:center;">
                    </div>
                </div>
            </div>
        </div>

        <div data-role="page" id="detail_page">
            <div data-role="header" data-position="fixed" data-tap-toggle="false" >
                <div style="margin:0.35em;" class="logo-back logo-300px" onclick="window.history.back();" ></div>
                <h1 id="record-detail-title">[Data(e.g. 2014-11-24)]</h1>
            </div>
            <div data-role="content">
                
                <div data-role="collapsible" data-inset="false" data-collapsed="false">
                    <h3>General</h3>
                    <ul data-role="listview" data-inset="false">
                        <li>
                            <span class="list-item-value">
                                <span id="record-detail-startTime">[Start time]</span> ~ <span id="record-detail-endTime">[End Time]</span>
                            </span>
                        </li>
                        <li>
                            <div class="logo-duration logo-300px"></div> 
                            <span class="list-item-value" id="record-detail-duration">Duration</span>
                        </li>
                        <li>
                            <div class="logo-energy logo-300px"></div>
                            <span class="list-item-value" >
                                <span id="record-detail-energy">Energy consumption</span> kWh
                            </span>
                        </li>
                        <li>
                            <div class="logo-co2reduction logo-300px"></div> 
                            <span class="list-item-value" >
                                <span id="record-detail-co2reduced">?</span> g CO<small>2</small> redeced
                            </span>
                        </li>
                    </ul>        
                </div> 

                <div data-role="collapsible" data-inset="false"> 
                    <h3>Expert</h3>
                    <ul data-role="listview" data-inset="false">
                        <li>
                            <div class="logo-efficiency logo-300px"></div>
                            <span class="list-item-value" >  
                                 <span id="record-detail-efficiency">Efficiency</span> %
                            </span>
                        </li>
                        <li>
                            <div class="logo-power logo-300px"></div> 
                            <span class="list-item-value" >
                                <span id="record-detail-peak-power">Peak power</span> W 
                            </span>
                        </li>
                        <li>
                            <div class="logo-current logo-300px"></div> 
                            <span class="list-item-value" > 
                                <span id="record-detail-peak-voltage">Peak current</span> A
                            </span>
                        </li>
                        <li>
                            <div class="logo-voltage logo-300px"></div> 
                            <span class="list-item-value" > 
                                <span id="record-detail-peak-current">Peak voltage</span> V
                            </span>
                        </li>
                    </ul>        
                </div> 

                <div data-role="collapsible" data-inset="false" data-collapsed="false">
                    <h3>Exercise place</h3>
                    <ul data-role="listview" data-inset="false">
                        <li>
                            <div class="logo-exercise-type-xxx logo-300px"></div>
                            <span class="list-item-value" id="record-detail-fitness-equipment-type">[equipment type]</span>
                        </li>
                        <li>
                            <div class="logo-address logo-300px"></div>
                            <span style="margin-left:40px;" id="record-detail-fitness-center-name">[fitness center name]</span><br>
                            <small style="margin-left:40px;" id="record-detail-fitness-center-addr">[fitness center address]</small>
                        </li>
                        <li>
                            <span id="record-detail-fitness-equipment-id" class="equipment-id-tag">[fitness equipment id]</span>    
                            <span id="record-detail-fitness-equipment-name">[fitness equipment name]</span>    
                        </li>
                    </ul>        
                </div> 
            </div>

        </div>

    </body>

</html>
