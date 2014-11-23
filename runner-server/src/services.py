# -*- coding: utf8 -*-
from bottle import run, request, response, post, get, template, route, static_file,\
  Bottle, HTTPResponse, HTTPError,debug,SimpleTemplate
from mysql.connector import connect
  
app = Bottle()

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
@app.route('/index')
def index():
    return template("tpl/index")

@app.route('/login', method = 'POST')
def login():
    userid = request.POST.get('userid')
    password = request.POST.get('password')
    ret = {}
    ret["success"] = False
    config = {'user':'phoenix', 'password':'admin','host':'localhost',
              'database':'phoenix','charset':'utf8','raw':True}#初始化数据库参数
    cnx = connect(**config)#新建连接   
    cursor=cnx.cursor()#新建游标
    cursor.execute('''select user_id FROM user_information ''')
    user_ids = cursor.fetchall() 
    print user_ids  
    for k in user_ids:
        if k[0]==userid:
            cursor.execute('''select * FROM user_information where user_information.user_id=%(phoenix.user_id)s''',{"phoenix.user_id":userid})
            information = cursor.fetchall()
            print information
            for k in information:                
                if k[1]==password:                     
                    ret["success"] = True
                    ret["user_id"] = userid
                    ret["password"] = password
                    ret["name"] = k[2]
                    ret["exercise_time"] = k[3]
                    ret["Energy_consumption"] = k[4]
                    ret["Electricity_generation"] = k[5]
                    print ret
                
    cursor.close()
    return ret

@app.route('/checkUserid', method = 'POST')
def checkuserid():
    userid = request.POST.get('userid')
    ret = {}
    ret["exist"] = False
    config = {'user':'phoenix', 'password':'admin','host':'localhost',
              'database':'phoenix','charset':'utf8','raw':True}#初始化数据库参数
    cnx = connect(**config)#新建连接   
    cursor=cnx.cursor()#新建游标
    cursor.execute('''select user_id FROM user_information ''')
    user_ids = cursor.fetchall()
    print "check if this user_id be used" 
    print user_ids 
    for k in user_ids: 
        if k[0]==userid:
            ret["exist"] = True
            print "this user_id is be used"
        
    return ret

@app.route('/signup', method = 'POST')
def signup():
    userid = request.POST.get('userid')
    password = request.POST.get('password')
    username = request.POST.get('userName')
    ret = {}
    ret["success"] = True
    config = {'user':'phoenix', 'password':'admin','host':'localhost',
              'database':'phoenix','charset':'utf8','raw':True}#初始化数据库参数
    cnx = connect(**config)#新建连接   
    cursor=cnx.cursor()#新建游标
    cursor.execute('''select user_id FROM user_information ''')
    user_ids = cursor.fetchall()
    for k in user_ids:
        if k[0] == userid:
            ret["success"] = False
            print "this user_id exit,can not signup"
            return ret
   
    cursor.execute("INSERT INTO user_information (user_id,password,name) VALUES (%s,%s,%s)",(userid,password,username))
    cnx.commit()  
    cursor.close()
    return ret  


app.run(host='localhost', port=8080)

  
