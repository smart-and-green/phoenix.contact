# -*- coding: utf8 -*-
import bottle,time,datetime,json,string,types
from datetime import  datetime
from bottle import run, request, response, post, get, template, route, static_file,\
  Bottle, HTTPResponse, HTTPError,debug,SimpleTemplate,os
from json import JSONDecoder
from beaker.middleware import SessionMiddleware
from bottle_MySQLPlugin import MySQLPlugin
import MySQLdb
  
app = bottle.default_app()

#==================================================================#
#class DateEncoder(json.JSONEncoder):                              #
#     def default(self,obj):                                       #
#         if isinstance(obj,datetime):                             #
#             return obj.__str__()                                 #
#         return json.JSONEncoder.default(self,obj)                #
#==================================================================#

#---------------------------------------------
@app.route('/js/<path>')
def server_js(path):
    return static_file(path, root='js')

@app.route('/css/<path>')
def server_css(path):
    return static_file(path, root='css')

@app.route('/css/images/<path>')
def server_img_gif(path):
    return static_file(path, root='css/images/')

@app.route('/css/images/icons-png/<path>')
def server_img_png(path):
    return static_file(path, root='css/images/icons-png/')

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
                    cr.execute('''select * FROM user_information where user_information.user_id=%(phoenix.user_id)s''',{"phoenix.user_id":userid})                     
                    nickname = cr.fetchall()
                    nickname = nickname[0][1]
                    print nickname
                    ret["success"] = True
                    ret["user_id"] = userid
                    ret["password"] = password
                    cr.execute('''select * FROM total_information where total_information.user_id=%(phoenix.user_id)s''',{"phoenix.user_id":userid})
                    total_information = cr.fetchall()
                    print "总信息:",total_information
                    for k in total_information:                                                                    
                        ret["userdata"] = {}
                        ret["userdata"]["name"] = nickname
                        ret["userdata"]["summary"] = {}                        
                        summary_duration = k[1].__str__()
                        print "转换成字符串的summary时间:",summary_duration  #json格式不能直接传time格式
                        ret["userdata"]["summary"]["duration"] = summary_duration
                        ret["userdata"]["summary"]["energy"] = k[2]
                   #     ret["userdata"]["summary"]["globalRank"] = k[3]
                        
                        ret["userdata"]["average"] = {}
                        average_duration = k[4]
                        cr.execute('''SELECT TIME_TO_SEC(%(average_duration)s)''',{"average_duration":average_duration})
                        average_duration = cr.fetchall()[0][0].__str__()
                        print "转换成秒的average时间:",average_duration
                        ret["userdata"]["average"]["duration"] = average_duration
                        ret["userdata"]["average"]["energy"] = k[5]
                   #     ret["userdata"]["average"]["globalRank"] = k[6]                        
                        
                    cr.execute('''SELECT COUNT(*) FROM total_information WHERE energy_summary>(SELECT energy_summary FROM total_information WHERE 
                                user_id=%(phoenix.user_id)s)''',{"phoenix.user_id":userid})
                    summary_rank=cr.fetchall()
                    summary_rank = summary_rank[0][0] + 1
                    ret["userdata"]["summary"]["globalRank"] = summary_rank
                        
                    cr.execute('''SELECT COUNT(*) FROM total_information WHERE energy_average>(SELECT energy_average FROM total_information WHERE 
                                  user_id=%(phoenix.user_id)s)''',{"phoenix.user_id":userid})
                    average_rank=cr.fetchall()
                    average_rank = average_rank[0][0] + 1
                    ret["userdata"]["average"]["globalRank"] = average_rank
                        
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
    print "zhixingdaozhe"
    return ret

@app.route('/user_exercise_history')
def user_exercise_history():
    return template('tpl/user_exercise_history')
    

@app.route('/getUserMonthExRecord', method = 'POST')
def getUserMonthExRecord(db):
    userid = request.POST.get('userid')
    queryYear = request.POST.get('year')
    queryMonth = request.POST.get('month')
    
    ret = {}
    print userid, queryYear, queryMonth
    cr = db.cursor()
    
    # test whether there are still record not loaded
    cr.execute(
        ''' select count(*) from exercise_information
            where
                user_id = %(userid)s and 
                start_time < %(start_datetime)s
        ''',
        {
            "userid": userid,
            "start_datetime": str(string.atoi(queryYear)) + "-" + str(string.atoi(queryMonth) + 1),
        }
    )
    if (cr.fetchall()[0][0] <= 0):
        ret["noMoreExRecord"] = True
    else:
        ret["noMoreExRecord"] = False

    # query the history of the given month
    count = cr.execute(
        ''' select * from exercise_information 
            where
                user_id = %(userid)s and
                EXTRACT(YEAR from start_time) = %(year)s and
                EXTRACT(MONTH from start_time) = %(month)s
            order by start_time desc
        ''',
        {
            "userid": userid,
            "year": string.atoi(queryYear),
            "month": string.atoi(queryMonth) + 1
        }
        # 脚本里月份是从0~11，数据库里月份是1~12，所以从脚本传递到数据库里要+1
    )
    ret["count"] = count
    ret["histories"] = []
    table = cr.fetchall()
    for row in table:
        record = {}
        record["equipment_id"] = row[1]
        record["startTime"] = row[2].__str__()
        record["endTime"] = row[3].__str__()
        record["energy"] = row[5]
        record["peakPower"] = row[6]
        record["efficiency"] = row[7]
        ret["histories"].append(record)
    print ret
    cr.close()
    return ret



@app.route('/getUserLast10History', method = 'POST')
def getUserLast10History(db):
    userid = request.POST.get('userid')
    cr=db.cursor()#新建游标
    cr.execute('''SELECT COUNT(*) FROM exercise_information WHERE (user_id=%(user_id)s)''',{"user_id":userid})
    number = cr.fetchall()
    number = number[0][0]
    if (number >=10): 
        print "该用户一共的锻炼记录超过10次:",number
        cr.execute('''SELECT * FROM exercise_information WHERE (user_id=%(user_id)s AND num>(%(number)s-10)''',{"user_id":userid,"number":number})
        Last10History = cr.fetchall()
        print "用户最后10条锻炼记录:",Last10History
    else:
        cr.execute('''SELECT * FROM exercise_information WHERE (user_id=%(user_id)s)''',{"user_id":userid})
        Last10History = cr.fetchall()
        print "用户最后10条锻炼记录,不足10条:",number,Last10History
    cr.close()
    ret = {}
    ret["lastIndex"] = number
    ret["histories"] = []
    for k in Last10History:
        s = {}
        s["startTime"] = k[0]
        s[1] = k[1]
        shijian1 = k[2].__str__()
        s["startTime"] = shijian1
        shijian2 = k[3].__str__()
        s["endTime"] = shijian2
        shijian3 = k[4].__str__()
        s["duration"] = shijian3
        s["energy"] = k[5]
        s["peakPower"] = 45
        s["efficiency"] = 85.7
        ret["histories"].append(s)
    print "数组里面的内容:",ret["histories"]
    return ret
        
    
@app.route('/checkUserid', method = 'POST')
def checkuserid(db):
    userid = request.POST.get('userid')
    ret = {}
    ret["exist"] = False
    cr=db.cursor()#新建游标
    cr.execute('''select user_id FROM user_login ''')
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
    ret["reason"] = 0
    cr=db.cursor()#新建游标
    cr.execute('''select user_id FROM user_login ''')
    user_ids = cr.fetchall()
    for k in user_ids:
        if k[0] == userid:
            ret["success"] = False
            ret["reason"] = 1
            print "this user_id exit,can not signup"
    
    if (ret["success"] == True):                       
        cr.execute("INSERT INTO user_login (user_id,password) VALUES (%s,%s)",(userid,password)) 
        db.commit()
        cr.execute("INSERT INTO total_information (user_id,exercise_number) VALUES (%s,%s)",(userid,0))
        db.commit()
        print "这能执行吧"
        if (username == ""):  
            print "这不会执行,前端已经写好了."           
            cr.execute("INSERT INTO user_information (user_id,nickname) VALUES (%s,%s)",(userid,userid))
            db.commit()
        else:
            cr.execute("INSERT INTO user_information (user_id,nickname) VALUES (%s,%s)",(userid,username))
            db.commit()
            print "怎么回事呢"
        print "注册成功"
    else:
        pass
    cr.close()
    return ret  

@app.route('/uploadExRecord', method = 'POST')
def uploadExRecord(db):
    cr = db.cursor()
    user_id = request.POST.get('userid')
    equipment_id = request.POST.get('equipmentid')
    start_time = request.POST.get('startTime')
    end_time = request.POST.get('endTime')
    energy = request.POST.get('energy')
    peak_power = request.POST.get('peakPower')
    efficiency = request.POST.get('efficiency')
    peak_current = request.POST.get('peakCurrent')
    peak_voltage = request.POST.get('peakVoltage')
    co2_reduced = request.POST.get('co2reduced')
#    cr.execute('''SELECT DATE_ADD(%(start_time)s,INTERVAL 1 MONTH)''',{"start_time":start_time})
#    start_time = cr.fetchall()[0][0].__str__()
#    cr.execute('''SELECT DATE_ADD(%(end_time)s,INTERVAL 1 MONTH)''',{"end_time":end_time})
#    end_time = cr.fetchall()[0][0].__str__()
    print ("userid:",user_id,"startTime:",start_time,"endTime:",end_time,
      "energy:",energy,"peakPower:",peak_power,"efficiency:",efficiency,
      "peakCurrent:",peak_current ,"peakVoltage:",peak_voltage,"equipmentid:",equipment_id,
      "co2reducded:",co2_reduced)        
    ret = {}
    ret["success"] = True
    cr.execute('''SELECT DATE(%(start_time)s)''',{"start_time":start_time})
    start_date = cr.fetchall()
    start_date = start_date[0][0]
    print "start_date:",start_date
    cr.execute('''SELECT DATE(%(end_time)s)''',{"end_time":end_time})
    end_date = cr.fetchall()
    end_date = end_date[0][0]
    print "end_date:",end_date
    cr.execute('''SELECT DATEDIFF(%(end_date)s,%(start_date)s)''',{"start_date":start_date,"end_date":end_date})
    diff_date = cr.fetchall()
    diff_date = diff_date[0][0]
    print "diff_date:",diff_date
    if (diff_date>=2):
        print "锻炼持续时间超过两天，数据无效"
        ret["success"] = False
        return ret
    elif (diff_date ==1):
        cr.execute('''SELECT TIME(%(start_time)s)''',{"start_time":start_time})
        start_time_du = cr.fetchall()[0][0]
        print "diff_date=1 不加date的start_time:",start_time_du
        cr.execute('''SELECT TIME(%(end_time)s)''',{"end_time":end_time})
        end_time_du = cr.fetchall()[0][0]
        print "diff_date=1 不加date的end_time:",end_time_du
        cr.execute('''SELECT SUBTIME(%(end_time_du)s,%(start_time_du)s)''',{"start_time_du":start_time_du,"end_time_du":end_time_du})
        duration_time = cr.fetchall()[0][0]
        cr.execute('''SELECT ADDTIME(%(duration_time)s,"24:00:00")''',{"duration_time":duration_time})
        duration_time = cr.fetchall()[0][0]
        print "diff_date == 1 duration_time:",duration_time
    else :
        cr.execute('''SELECT TIME(%(start_time)s)''',{"start_time":start_time})
        start_time_du = cr.fetchall()[0][0]
        print "diff_date=0 不加date的start_time:",start_time_du
        cr.execute('''SELECT TIME(%(end_time)s)''',{"end_time":end_time})
        end_time_du = cr.fetchall()[0][0]
        print "diff_date=0 不加date的end_time:",end_time_du
        cr.execute('''SELECT SUBTIME(%(end_time_du)s,%(start_time_du)s)''',{"start_time_du":start_time_du,"end_time_du":end_time_du})
        duration_time = cr.fetchall()[0][0]
        print "diff_date == 0 duration_time:",duration_time
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
    cr.execute('''INSERT INTO exercise_information (user_id,equipment_id,start_time,end_time,duration_time,energy,
                  peak_power,efficiency,peak_current,peak_voltage,co2_reduced,num) 
               VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)''',(user_id,equipment_id,start_time,end_time,duration_time,energy,
                                                 peak_power,efficiency,peak_current,peak_voltage,co2_reduced,num))
    cr.execute('''UPDATE total_information SET energy_summary=(energy_summary+%(energy)s),exercise_number=%(num)s WHERE (user_id= %(userid)s)''',
                  {"energy":energy,"num":num,"userid":user_id})
    print "更新energy_summary,exercise_number成功"
    cr.execute('''SELECT energy_summary FROM total_information WHERE user_id= %(user_id)s''',{"user_id":user_id})
    energy_summary = cr.fetchall()[0][0]
    print "energy_summary:",energy_summary
    cr.execute('''UPDATE total_information SET energy_average=
                     (%(energy_summary)s/%(num)s)
                      WHERE (user_id= %(user_id)s)''',{"num":num,"energy_summary":energy_summary,"user_id":user_id})
    print "更新energy_average成功"
    cr.execute('''SELECT duration_summary FROM total_information WHERE user_id= %(user_id)s''',{"user_id":user_id})
    duration_summary = cr.fetchall()[0][0].__str__() 
    print "duration_summary:",duration_summary
    cr.execute('''UPDATE total_information SET duration_summary=(ADDTIME(%(duration_summary)s,%(duration_time)s))
                WHERE (user_id=%(user_id)s)''',{"duration_summary":duration_summary,"duration_time":duration_time,"user_id":user_id}) 
    print "duration_summary更新成功"  
    cr.execute('''SELECT TIME_TO_SEC(ADDTIME(%(duration_summary)s,%(duration_time)s))''',{"duration_summary":duration_summary,
                                                                                          "duration_time":duration_time})
    dur_sec = cr.fetchall()[0][0]#转化为秒的时间
    print "duration_summary转化为秒:",dur_sec
    dur_sec_avg = dur_sec/num
    print "平均每次运动的秒数:",dur_sec_avg
    cr.execute('''UPDATE total_information SET duration_average=(SEC_TO_TIME(%(dur_sec_avg)s)) 
                  WHERE user_id=%(user_id)s''',{"dur_sec_avg":dur_sec_avg,"user_id":user_id})
    print "更新平均运动时间成功"

#----------------------------------------------------------------------------------------------------------

#-----------------记录每个用户每月的数据记录 ----------------------------------------------------------------   
    cr.execute('''SELECT COUNT(*) FROM month_information WHERE (user_id=%(user_id)s AND year=%(year)s AND month=%(month)s)''',
                  {"user_id":user_id,"year":year,"month":month})
    number = cr.fetchall()
    number = number[0][0]#检查数据库中是否有这个月的记录，1表示有，0表示没有，若没有则创建这个月的记录，有则更新
    print "检查数据库中是否有这个月的记录 1表示有，0表示没有:",number
    if(number == 0):#无这个月的记录
        cr.execute('''INSERT INTO month_information (user_id,year,month,month_energy,month_time) VALUES (%s,%s,%s,%s,%s)''',
                      (user_id,year,month,energy,duration_time))
        print "生成本月数据记录成功"
    elif (number == 1):#有这个月的记录
        print "ssssssssssss"
        cr.execute('''UPDATE month_information SET month_energy=month_energy+%(energy)s,month_time=ADDTIME(month_time,%(time)s) WHERE 
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
    print "检查数据库中是否有这个星期的记录 1表示有，0表示没有:",number
    if(number == 0):
        cr.execute('''INSERT INTO week_information (user_id,year,week,week_energy,week_time) VALUES (%s,%s,%s,%s,%s)''',
                      (user_id,year,week,energy,duration_time))
        print "生成这个星期数据记录成功"
    elif (number == 1):
        cr.execute('''UPDATE week_information SET week_energy=week_energy+%(energy)s,week_time=ADDTIME(week_time,%(time)s) WHERE 
                    (user_id=%(user_id)s AND year=%(year)s AND week=%(week)s) ''',{"energy":energy,"time":duration_time,"user_id":user_id,"year":year,"week":week})
        print "更新这个星期数据成功"
    else:
        pass
#-------------------------------------------------------------------------------------------------
            
    print "提交成功"
    cr.close()    
    return ret




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

  
