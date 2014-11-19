# -*- coding: utf-8 -*-

from bottle import run, request, response, post, get, template, route, static_file, redirect, Bottle, HTTPResponse, HTTPError,debug,SimpleTemplate,abort

app = Bottle()

""" 
    @notice
        do not contain any Chinese characters, only ASCII!
    @suggest
        do not use too much Chinese characters, please use English instead
        so as to reduce encoding errors.
"""

#---------------------------------------------
@app.route('/js/<path>')
def server_js(path):
    return static_file(path, root='js')

@app.route('/css/<path>')
def server_css(path):
    return static_file(path, root='css')

@app.route('/tpl/<path>')
def server_tpl(path):
    return static_file(path, root='tpl')
#---------------------------------------------


""" test part
"""
@app.route('/test')
def test():
    return "<body>hello world!</body>"
    
@app.route('/page')
def page():
    print ("page")
    return template("tpl/page")

@app.route('/ajaxtest', method='POST')
def ajaxtest():
    print("start")
    val = request.POST.get('key')
    print ("val" + val)
    ret = {}
    ret['meg'] = '1'
    ret['key'] = val
    print ("end")
    return (ret)


""" 
    @brief
        home page, only this page
"""
@app.route('/index')
def index():
    return template("tpl/index")

@app.route('/login', method = 'POST')
def login():
    userid = request.POST.get('userid')
    password = request.POST.get('password')
    ret = {}
    if (userid == "123456") and (password == "123456"):
        """ allow
        """
        ret["success"] = True
    elif (userid == "adolli") and (password == "123456"):
        ret["success"] = True
    else:
        """ deny
        """
        ret["success"] = False
    return ret

@app.route('/checkUserid', method = 'POST')
def checkuserid():
    userid = request.POST.get('userid')
    ret = {}
    if (userid == "123456"):
        ret["exist"] = True
    else:
        ret["exist"] = False
    return ret

@app.route('/signup', method = 'POST')
def signup():
    userid = request.POST.get('userid')
    password = request.POST.get('password')
    username = request.POST.get('username')
    ret = {}
    ret["success"] = True
    if (userid == "123456"):
        ret["success"] = False
        ret["reason"] = 1
    elif (password == ""):
        ret["success"] = False
        ret["reason"] = 2
        
    return ret

app.run(host='localhost', port=8080)








