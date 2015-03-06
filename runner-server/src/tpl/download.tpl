<!DOCTYPE html>
<html>
    <head>
        <title>runner</title>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" /> 
        <link rel="stylesheet" type="text/css" href="css/runner-theme-w.css" />
        <link rel="stylesheet" type="text/css" href="css/jquery.mobile.icons.min.css" />
        <link rel="stylesheet" type="text/css" href="css/jquery.mobile.structure-1.4.5.css" />
        <link rel="stylesheet" type="text/css" href="css/runner.css" />
        <script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
        <script type="text/javascript" src="js/jquery.mobile-1.4.5.min.js"></script>
        
        <script type="text/javascript" src="js/runner-global.js"></script>
        <script type="text/javascript" src="js/download-util.js"></script>

        </head>

    <body>


    	<div data-role="page" id="login">
            <script type="text/javascript">
               

            </script>
    		<div data-role="header" data-position="fixed" data-tap-toggle="false">
                <h1>Download</h1>
            </div>
            <div data-role="content">
                <div data-role="collapsible" data-inset="false" data-collapsed="false">
                    <h3>For android mobile</h3>
                    <ul data-role="listview" data-inset="false">
                         <li  id="download-remote-version">
                            <a  href="#" onclick="downloadAndSave('./download/runner');" >
                                <span style="color:green;">runner.apk</span><br>
                            </a>
                        </li>
                    </ul>         
                </div> 
                <small>Remote version. You can access our system in any where of the world. The data of different version are seperated. That means you can not cross-using two apps. If your mobile can access the internet, we strongly suggest to download the remote version.</small>
                
                <div data-role="collapsible" data-inset="false" data-collapsed="false" style="margin-top:2em;">
                    <h3>For android mobile local version</h3>
                    <ul data-role="listview" data-inset="false">
                        <li id="download-local-version">
                            <a href="#" onclick="downloadAndSave('./download/runner-localVersion')">
                                <span style="color:green;">runner-localVersion.apk</span><br>
                            </a>
                        </li>
                    </ul>         
                </div>
                <small>Local version. Only for xplore 2015 site at phoenix contact.</span>
            </div>
    	</div>
    </body>
</html>

