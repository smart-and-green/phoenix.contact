/*global PhoneGap*/

var Nfc = function() {

};

Nfc.prototype = {  
          
    read: function(success, error, password){  
        PhoneGap.exec(success, error, "NfcPlugin", "read", [password]);  
    }
}; 

PhoneGap.addConstructor(function() {  
    if (!window.plugins) {
    	window.plugins = { };
    }
    window.plugins.nfc = new Nfc(); 
});  

