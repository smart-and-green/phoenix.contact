/*global PhoneGap*/

var Nfc = function() {

};

Nfc.prototype = {  
          
    read: function(success, error, password){  
        PhoneGap.exec(success, error, "NfcPlugin", "read", [password]);  
    },

    // @param blockAndDataList is an json object
    // structure as below 
    // [{
    //     blockIndex: 1,
    //     data: [0xa, 0xb, 0xc, 0xd, 0xe, 0xf, 0x1, 0x1]
    //  },
    //  {
    //     blockIndex: 2,
    //     data: [0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1, 0x1]
    //  }]
    write: function(success, error, password, blockAndDataList) {
        PhoneGap.exec(success, error, "NfcPlugin", "write", [password, blockAndDataList]);  
    },

    // read and write a tag in the same time
    // if blockAndDataList is null, this method is the same as read
    readThenWrite: function(success, error, password, blockAndDataList) {
        PhoneGap.exec(success, error, "NfcPlugin", "readThenWrite", [password, blockAndDataList]);  
    },
}; 

PhoneGap.addConstructor(function() {  
    if (!window.plugins) {
    	window.plugins = { };
    }
    window.plugins.nfc = new Nfc(); 
});  

