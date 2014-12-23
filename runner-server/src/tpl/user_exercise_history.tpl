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