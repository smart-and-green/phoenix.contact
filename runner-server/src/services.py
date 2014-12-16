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
                        
#                        ret["userdata"]["lastWeekSummary"] = {}
#                        ret["userdata"]["lastWeekSummary"]["duration"] = k[7]
#                        ret["userdata"]["lastWeekSummary"]["energy"] = k[8]
#                        ret["userdata"]["lastWeekSummary"]["globalRank"] = k[9]
                        
                    cr.execute('''SELECT COUNT(*) FROM total_information WHERE energy_summary>(SELECT energy_summary FROM total_information WHERE 
                                user_id=%(phoenix.user_id)s)''',{"phoenix.user_id":userid})
                    summary_rank=cr.fetchall()
                    summary_rank = summary_rank[0][0] + 1
                        
                    cr.execute('''SELECT COUNT(*) FROM total_information WHERE energy_average>(SELECT energy_average FROM total_information WHERE 
                                  user_id=%(phoenix.user_id)s)''',{"phoenix.user_id":userid})
                    average_rank=cr.fetchall()
                    average_rank = average_rank[0][0] + 1
                        
                    now_time = "2015-11-15 10:12:56"
                    cr.execute('''SELECT YEAR(%(now_time)s)''',{"now_time":now_time})
                    year = cr.fetchall()
                    year = year[0][0]#得到当前的年份
                    print "当前的年份:",year 
    
                    cr.execute('''SELECT MONTH(%(now_time)s)''',{"now_time":now_time})
                    month = cr.fetchall()
                    month = month[0][0]#得到当前的月份
                    print "当前的月份:",month  

                    cr.execute('''SELECT WEEK(%(now_time)s,2)''',{"now_time":now_time})
                    week = cr.fetchall()
                    week = week[0][0]#得到这是今年第几个星期
                    print "第几个星期:",week
                    
#---------------------------本月目前的排名---------------------------------------------------------------------------
                    cr.execute('''SELECT month_energy FROM month_information WHERE(user_id=%(user_id)s AND year=%(year)s AND month=%(month)s)''',
                                {"user_id":userid,"year":year,"month":month})
                    month_energy = cr.fetchall()
                    if (month_energy):  #本月有产生能量    
                        print "能量元组",month_energy
                        month_energy = month_energy[0][0]
                        print "本月产生的能量:",month_energy             
                        cr.execute('''SELECT COUNT(*) FROM month_information WHERE (month_energy>%(month_energy)s AND year=%(year)s AND month=%(month)s) ''',
                                   {"month_energy":month_energy,"year":year,"month":month})
                        month_rank = cr.fetchall()
                        month_rank = month_rank[0][0]+1 
                        print "本月目前排名:",month_rank 
                    else:     #本月无产生能量
                        cr.execute('''SELECT COUNT(*) FROM month_information WHERE (month_energy>0 AND year=%(year)s AND month=%(month)s) ''',
                                   {"year":year,"month":month})
                        month_rank = cr.fetchall()
                        month_rank = month_rank[0][0]+1  
                        print "本月没有锻炼目前排名:",month_rank 
#-------------------------------------------------------------------------------------------------------                 

#-----------------------本星期目前的排名-------------------------------------------------------------------
                    cr.execute('''SELECT week_energy FROM week_information WHERE(user_id=%(user_id)s AND year=%(year)s AND week=%(week)s)''',
                                {"user_id":userid,"year":year,"week":week})
                    week_energy = cr.fetchall()
                    if (week_energy):  #本星期有产生能量     
                        print "能量元组",week_energy
                        week_energy = week_energy[0][0]
                        print "本星期产生的能量:",week_energy             
                        cr.execute('''SELECT COUNT(*) FROM week_information WHERE (week_energy>%(week_energy)s AND year=%(year)s AND week=%(week)s) ''',
                                   {"week_energy":week_energy,"year":year,"week":week})
                        week_rank = cr.fetchall()
                        week_rank = week_rank[0][0]+1 
                        print "本星期目前排名:",week_rank 
                    else:     #本星期无产生能量
                        cr.execute('''SELECT COUNT(*) FROM week_information WHERE (week_energy>0 AND year=%(year)s AND week=%(week)s) ''',
                                   {"year":year,"week":week})
                        week_rank = cr.fetchall()
                        print week_rank
                        if (week_rank):
                            week_rank = week_rank[0][0]+1
                        else:                  
                            week_rank = 1  
                        print "本星期没有锻炼,本星期目前排名:",week_rank
#-------------------------------------------------------------------------------------------------------

#----------------------最后10条锻炼记录----------------------------------------------------------------------
                    cr.execute('''SELECT COUNT(*) FROM exercise_information WHERE (user_id=%(user_id)s)''',{"user_id":userid})
                    num = cr.fetchall()
                    num = num[0][0]
                    print "该用户在表中一共的记录条数:",num
                    cr.execute('''SELECT * FROM exercise_information WHERE(user_id=%(user_id)s AND num>(%(num1)s-10) AND num<=(%(num2)s))''',
                                {"user_id":userid,"num1":num,"num2":num})
                    last_10_history = cr.fetchall()
                    print "最近10条历史记录:",last_10_history                    
#------------------------------------------------------------------------------------------------------ 

#---------------------------10个星期的历史记录---------------------------------------------------------------                  
                    if (week>=10):
                        cr.execute('''SELECT * FROM week_information WHERE(user_id=%(user_id)s AND year=%(year)s AND week>(%(week1)s-10) AND week<=(%(week2)s))''',
                                    {"user_id":userid,"year":year,"week1":week,"week2":week})
                        week_10_history = cr.fetchall()
                        print "最近10个星期历史记录:",week_10_history
                    elif (1<=week<10): 
                        cr.execute('''SELECT * FROM week_information WHERE(user_id=%(user_id)s AND year=%(year)s AND week>0 AND week<=(%(week)s))''',
                                    {"user_id":userid,"year":year,"week":week})
                        week_10_history1 = cr.fetchall()
                        print "最近10个星期的记录，今年的:",week_10_history1
                        
                        week_lastyear = 10-week
                        cr.execute('''SELECT * FROM week_information WHERE(user_id=%(user_id)s AND year=(%(year)s-1) AND week>(52-%(week_lastyear)s) AND week<=52)''',
                                    {"user_id":userid,"year":year,"week_lastyear":week_lastyear})                        
                        week_10_history2 = cr.fetchall()
                        print "最近10个星期的记录，去年的:",week_10_history2
                    else:
                        pass                                                          
#------------------------------------------------------------------------------------------------------ 

#----------------------------10个月的历史记录-------------------------------------------------------------
                    if (month>=10):
                        cr.execute('''SELECT * FROM month_information WHERE(user_id=%(user_id)s AND year=%(year)s AND month>(%(month1)s-10) AND month<=(%(month2)s))''',
                                    {"user_id":userid,"year":year,"month1":month,"month2":month})
                        month_10_history = cr.fetchall()
                        print "最近10个月历史记录:",month_10_history
                    elif (1<=month<10): 
                        cr.execute('''SELECT * FROM month_information WHERE(user_id=%(user_id)s AND year=%(year)s)''',
                                    {"user_id":userid,"year":year})
                        month_10_history1 = cr.fetchall()
                        print "最近10个月的记录，今年的:",week_10_history1
                        
                        month_lastyear = 10-month
                        cr.execute('''SELECT * FROM month_information WHERE(user_id=%(user_id)s AND year=(%(year)s-1) AND month>(12-%(month_lastyear)s) AND month<=12)''',
                                    {"user_id":userid,"year":year,"month_lastyear":month_lastyear})                        
                        month_10_history2 = cr.fetchall()
                        print "最近10个月的记录，去年的:",month_10_history2
                    else:
                        pass  
#------------------------------------------------------------------------------------------------------                                                                  
                    print "总能量排名:",summary_rank
                    print "平均能量排名:",average_rank
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

@app.route('/data')#上传健身数据到数据库
def data(db):
    user_id = 'jim'
    equipment_id = 'bike'
    start_time = "2014-12-12 10:10:10"
    end_time = 20141212101111
    duration_time = "000001"
    energy = 1
    cr = db.cursor()
    
    cr.execute('''SELECT YEAR(%(start_time)s)''',{"start_time":start_time})
    year = cr.fetchall()
    year = year[0][0]#得到当前的年份
    print "当前的年份:",year 
    
    cr.execute('''SELECT MONTH(%(start_time)s)''',{"start_time":start_time})
    month = cr.fetchall()
    month = month[0][0]#得到当前的月份
    print "当前的月份:",month  

    cr.execute('''SELECT WEEK(%(start_time)s,2)''',{"start_time":start_time})
    week = cr.fetchall()
    week = week[0][0]#得到这是今年第几个星期
    print "第几个星期:",week
    
#-----------------将本次运动的数据存储到数据库--------------------------------------------------------------------
    cr.execute('''SELECT COUNT(*) FROM exercise_information WHERE (user_id=%(user_id)s)''',{"user_id":user_id})
    num = cr.fetchall()
    num = num[0][0]
    print num #该用户之前一共有多少条记录
    num = num + 1
    cr.execute('''INSERT INTO exercise_information (user_id,equipment_id,start_time,end_time,duration_time,energy,num) 
               VALUES (%s,%s,%s,%s,%s,%s,%s)''',(user_id,equipment_id,start_time,end_time,duration_time,energy,num))
#----------------------------------------------------------------------------------------------------------

#-----------------记录每个用户每月的数据记录 ----------------------------------------------------------------   
    cr.execute('''SELECT COUNT(*) FROM month_information WHERE (user_id=%(user_id)s AND year=%(year)s AND month=%(month)s)''',
                  {"user_id":user_id,"year":year,"month":month})
    number = cr.fetchall()
    number = number[0][0]#检查数据库中是否有这个月的记录，1表示有，0表示没有，若没有则创建这个月的记录，有则更新
    print "检查数据库中是否有这个月的记录:",number
    if(number == 0):
        cr.execute('''INSERT INTO month_information (user_id,year,month,month_energy,month_time) VALUES (%s,%s,%s,%s,%s)''',
                      (user_id,year,month,energy,duration_time))
        print "生成本月数据记录成功"
    elif (number == 1):
        cr.execute('''UPDATE month_information SET month_energy=month_energy+%(energy)s,month_time=month_time+%(time)s WHERE 
                    (user_id=%(user_id)s AND year=%(year)s AND month=%(month)s) ''',{"energy":energy,"time":duration_time,"user_id":user_id,"year":year,"month":month})
        print "更新本月数据成功"
    else:
        pass
#-------------------------------------------------------------------------------------------------------

#---------------记录每个用户每星期的数据记录-------------------------------------------------------------------
    cr.execute('''SELECT COUNT(*) FROM week_information WHERE (user_id=%(user_id)s AND year=%(year)s AND week=%(week)s)''',
                  {"user_id":user_id,"year":year,"week":week})
    number = cr.fetchall()
    number = number[0][0]#检查数据库中是否有这个月的记录，1表示有，0表示没有，若没有则创建这个月的记录，有则更新
    print "检查数据库中是否有这个星期的记录:",number
    if(number == 0):
        cr.execute('''INSERT INTO week_information (user_id,year,week,week_energy,week_time) VALUES (%s,%s,%s,%s,%s)''',
                      (user_id,year,week,energy,duration_time))
        print "生成这个星期数据记录成功"
    elif (number == 1):
        cr.execute('''UPDATE week_information SET week_energy=week_energy+%(energy)s,week_time=week_time+%(time)s WHERE 
                    (user_id=%(user_id)s AND year=%(year)s AND week=%(week)s) ''',{"energy":energy,"time":duration_time,"user_id":user_id,"year":year,"week":week})
        print "更新这个星期数据成功"
    else:
        pass
#-------------------------------------------------------------------------------------------------
            
    print "提交成功"
    return "提交成功了！！~~"
    cr.close()

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

  
