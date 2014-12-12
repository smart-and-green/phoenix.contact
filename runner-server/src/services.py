# -*- coding: utf8 -*-
import bottle
from bottle import run, request, response, post, get, template, route, static_file,\
  Bottle, HTTPResponse, HTTPError,debug,SimpleTemplate,os
from json import JSONDecoder
from beaker.middleware import SessionMiddleware
from bottle_MySQLPlugin import MySQLPlugin
import MySQLdb
  
app = bottle.default_app()

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

mysql = MySQLPlugin(dbfile='phoenix')
app.install(mysql)


@app.route('/index')
def index():
    return template("tpl/index")

@app.route('/login', method = 'POST')
def login(db):
    userid = request.POST.get('userid')
    password = request.POST.get('password')
    ret = {}
    ret["success"] = False
    cr=db.cursor()#新建游标 
    cr.execute('''select user_id FROM user_login ''')
    user_ids = cr.fetchall() 
    print user_ids  
    for k in user_ids:
        if k[0]==userid:
            cr.execute('''select * FROM user_login where user_login.user_id=%(phoenix.user_id)s''',{"phoenix.user_id":userid})
            information = cr.fetchall()
            print information
            for k in information:                
                if k[1]==password:                     
                    ret["success"] = True
                    ret["user_id"] = userid
                    ret["password"] = password
                    cr.execute('''select * FROM total_information where total_information.user_id=%(phoenix.user_id)s''',{"phoenix.user_id":userid})
                    total_information = cr.fetchall()
                    print total_information
                    for k in total_information:                                                                    
                        ret["userdata"] = {}
                        ret["userdata"]["summary"] = {}
                        ret["userdata"]["summary"]["duration"] = k[1]
                        ret["userdata"]["summary"]["energy"] = k[2]
                        ret["userdata"]["summary"]["globalRank"] = k[3]
                        
                        ret["userdata"]["average"] = {}
                        ret["userdata"]["average"]["duration"] = k[4]
                        ret["userdata"]["average"]["energy"] = k[5]
                        ret["userdata"]["average"]["globalRank"] = k[6]
                        
                        ret["userdata"]["lastWeekSummary"] = {}
                        ret["userdata"]["lastWeekSummary"]["duration"] = k[7]
                        ret["userdata"]["lastWeekSummary"]["energy"] = k[8]
                        ret["userdata"]["lastWeekSummary"]["globalRank"] = k[9]
                        print ret                
    cr.close()
    return ret

@app.route('/checkUserid', method = 'POST')
def checkuserid(db):
    userid = request.POST.get('userid')
    ret = {}
    ret["exist"] = False
    cr=db.cursor()#新建游标
    cr.execute('''select user_id FROM user_information ''')
    user_ids = cr.fetchall()
    print "check if this user_id be used" 
    print user_ids 
    for k in user_ids: 
        if k[0]==userid:
            ret["exist"] = True
            print "this user_id is be used"
        
    return ret

@app.route('/signup', method = 'POST')
def signup(db):
    userid = request.POST.get('userid')
    password = request.POST.get('password')
    username = request.POST.get('userName')
    ret = {}
    ret["success"] = True
    cr=db.cursor()#新建游标
    cr.execute('''select user_id FROM user_information ''')
    user_ids = cr.fetchall()
    for k in user_ids:
        if k[0] == userid:
            ret["success"] = False
            print "this user_id exit,can not signup"
            return ret
   
    cr.execute("INSERT INTO user_information (user_id,password,name) VALUES (%s,%s,%s)",(userid,password,username))
    cnx.commit()  
    cr.close()
    return ret  

@app.route('/uploadExRecord', method = 'POST')
def uploadExRecord(db):
    userid = request.POST.get('userid')
    exerciseData = request.POST.get('exerciseData')
    equipmentid = request.POST.get('equipmentid')
    print exerciseData
    print equipmentid

    

session_opts = {
    'session.type': 'file',
    'session.cookie_expires': True,
    'session.data_dir': os.path.join('/MyWorkspace/jcp1/ws', 'session'),
    'session.auto': True
}

app = SessionMiddleware(app, session_opts)

debug(True)
#run(app=app,server='gevent')
#WebSocketHandler.prevent_wsgi_call = True
#server = gevent.pywsgi.WSGIServer(("0.0.0.0", 8080), handle_websocket,handler_class=WebSocketHandler)
#server = gevent.pywsgi.WSGIServer(("", 8080), app,handler_class=WebSocketHandler)
#server.serve_forever()

#run(app=app, server='gevent', host='127.0.0.1', port=8080, interval=1, reloader=False, quiet=False, plugins=None, debug=True, listener=("", 8080), handler_class=WebSocketHandler)
#===========================================================================================================================================
if __name__ == "__main__":
    run(host="127.0.0.1", port=8080)
else:
    application = app
#=============================================================================================================================================

#bottle.run(app=app)

  
