// 使用JS实现下载.jpg、.doc、.txt、.rar、.zip等文件的方法(参数 imgOrURL 为需要下载的图片的URL地址)
// 使用该方法实现下载压缩文件时会有网页错误信息提示
// .doc、.rar、.zip 文件可以直接通过文件地址下载，
// 如：<a href="../Images/test.doc" >点击下载文件</a> <a href="../Images/test.zip" >点击下载文件</a>
function saveImageAs(imgOrURL) {
    if (typeof imgOrURL == 'object')
        imgOrURL = imgOrURL.src;
    window.win = open (imgOrURL);
    setTimeout('win.document.execCommand("SaveAs")', 500);
}
// 使用JS实现下载.txt、.doc、.txt、.rar、.zip等文件的方法(参数 fileURL 为需要下载的图片的URL地址)
// 使用该方法实现下载压缩文件时不会有网页错误信息，但是不能使用该方法下载.jpg图片文件
// .doc、.rar、.zip 文件可以直接通过文件地址下载，
// 如：<a href="../Images/test.doc" >点击下载文件</a> <a href="../Images/test.zip" >点击下载文件</a>
function downloadAndSave(fileURL){
    var fileURL=window.open (fileURL,"_blank","height=0,width=0,toolbar=no,menubar=no,scrollbars=no,resizable=on,location=no,status=no");
    fileURL.document.execCommand("SaveAs");
    //fileURL.window.close();
    //fileURL.close();
}

