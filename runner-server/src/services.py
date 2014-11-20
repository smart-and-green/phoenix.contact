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
    config = {'user':'root', 'password':'admin','host':'localhost',
              'database':'phoenix','charset':'utf8','raw':True}#初始化数据库参数
    cnx = connect(**config)#新建连接   
    cursor=cnx.cursor()#新建游标
    cursor.execute('''select name FROM user_information ''')
    names = cursor.fetchall() 
    print names   
    for k in names:
        if k[0]==userid:
            cursor.execute('''select * FROM user_information where user_information.name=%(phoenix.name)s''',{"phoenix.name":userid})
            information = cursor.fetchall()
            print information
            for k in information:                
                if k[1]==password:                     
                    ret["success"] = True
                    ret["name"] = userid
                    ret["password"] = password
                    ret["exercise_time"] = k[2]
                    ret["Energy_consumption"] = k[3]
                    ret["Electricity_generation"] = k[4]
                    print ret
                
    cursor.close()
    return ret


app.run(host='localhost', port=8080)

  
