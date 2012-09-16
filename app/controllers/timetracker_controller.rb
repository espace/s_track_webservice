#webservice interface which we will use in sTrack to import time entries easily
class TimetrackerController < ApplicationController
  skip_before_filter :check_if_login_required
  before_filter :authenticate
  def authenticate
     authenticate_or_request_with_http_basic('Administration') do |username, password|
       md5_of_password = Digest::MD5.hexdigest(password)
       username == 'admin' && md5_of_password == '5ebe2294ecd0e0f08eab7690d2a6ee69'
     end
   end
  #GET /timetracker.xml
  def track
    @users=params[:user_ids]
    @projects=params[:project_ids]
    @month=params[:month]
    @year=params[:year]
    @result=Project.find_by_sql("SELECT projects.id Project_ID,projects.name Project_Name,sum(hours) TrackerTime,trackers.name Tracker_Name,trackers.id Tracker_ID FROM projects INNER JOIN time_entries ON 
                                projects.id=time_entries.project_id INNER JOIN issues ON time_entries.issue_id=issues.id INNER JOIN trackers on issues.tracker_id=trackers.id"+
                               ((@month!=nil || @year!=nil || @projects!=nil || @users!=nil)?" WHERE "+((@month!=nil)?"tmonth="+@month:"")+
                               ((@month!=nil && @year!=nil)?" and ":"")+((@year!=nil)?"tyear="+@year:"")+(((@month!=nil || @year!=nil) && @users!=nil)?" and ":"")+
                               ((@users!=nil)?"time_entries.user_id in "+@users:"")+(((@month!=nil || @year!=nil || @users!=nil) && @projects!=nil)?" and ":"")+
                               ((@projects!=nil)?"time_entries.project_id in "+@projects:"")+" GROUP BY projects.name,issues.tracker_id ":""))
    respond_to do |format|
          format.xml  { render :xml => @result }
    end
  end
  def getprojects
    @result=Project.all(:select => "name,id")
    respond_to do |format|
         format.xml  { render :xml => @result }
    end
  end
  def getusers
    @result=User.all(:select => "id,firstname,lastname,mail")
    respond_to do |format|
         format.xml  { render :xml => @result }
    end
  end
  def gettrackers
    @result=Tracker.all
    respond_to do |format|
         format.xml  { render :xml => @result }
    end
  end
end