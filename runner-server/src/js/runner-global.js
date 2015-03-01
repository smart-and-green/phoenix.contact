
// the global app definition goes here.


// 一度电为0.997 kg CO2排放量
// 一度电为3600 kJ
// 则1 kJ 对应 0.27694 g CO2排放量
var CO2_REDUCTION_GRAM_PER_1kWh = 997.0;
var CO2_REDUCTION_GRAM_PER_1kJ = 0.27694;

var SERVER_ADDRESS = "http://192.168.1.104:8080";

function secondsToDurationStr(seconds) {
    var sec = parseInt(seconds % 60);
    var minutes = parseInt(seconds / 60);
    var min = parseInt(minutes % 60);
    var hour = parseInt(minutes / 60);
    var ret = sec + "s";
    if (hour != 0) {
        ret = hour + "h " + min + "m " + ret;
    } else if (min != 0) {
        ret = min + "m " + ret;
    }
    return ret;
}

