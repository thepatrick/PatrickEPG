class EpgController < ApplicationController
  
  
  session :off #, :except => [:index, ...]
  
  def index
    redirect_to :action => :on_now
  end
  
  def crj
    render_json current_recordings.to_json
  end
  
  def current_recordings
    
    cond = "state IN ('New', 'Recording')"
    recordings = Recording.find :all, :conditions => [cond]
    
    recordings_by_program = []
    
    recordings.each do |r|
      recordings_by_program[r.program_id] = r
    end
    
    recordings_by_program  
    
  end
  
  def on_now
    
    #@on = Schedule.find(:all, :conditions => ["start_time < now() and (start_time + (duration || ' minutes')::interval) > now()"])
    
    @channels = Channel.find(:all, :order => :channel)
    
    sql = '((start_time between ? and ?) or start_time < ? and (start_time + (duration || \' minutes\')::interval) > ?)'
    
    # find start of hour
    base_time = Time.new
    hours_to_get = 1.hours
    
    if(base_time.min < 30) 
      base_time = base_time - base_time.min.minutes
    elsif(base_time.min >= 30)
      base_time = base_time - (base_time.min - 30).minutes
    end
    
    base_time = base_time - (base_time.sec).seconds
    
        
    start_time = base_time
    end_time = (start_time + hours_to_get) - 1.second
    
    start_time.utc
    end_time.utc
    
    # cache stations, scheduled shows and programs
    stations = Station.find :all
    
    @station_array = []
    stations.each do |t|
      @station_array[t.id] = t
    end    
    
    on = Schedule.find(:all, :conditions => [sql, (start_time), end_time, start_time, start_time], :order => 'station_id, start_time')
    
    @on_array = []
    @prog_id_array = []
    on.each do |t|
      if(@on_array[t.station_id].nil?)
        @on_array[t.station_id] = []
      end
      @on_array[t.station_id][@on_array[t.station_id].length] = t
      @prog_id_array[@prog_id_array.length] = t.program_id
    end
    
    progs = Program.find(:all, :conditions => ['id in (?)', @prog_id_array])
    @progs_array = []
    progs.each do |t|
      @progs_array[t.id] = t
    end
    
    
    @zero_time = start_time
    @end_time = end_time.localtime
    
    start_time.localtime
    
    display_time_start = start_time
    display_time_stop = display_time_start + hours_to_get
    
    @times_on_display = []
    while display_time_start < display_time_stop do
      @times_on_display[@times_on_display.length] = display_time_start
      display_time_start = display_time_start + 30.minutes
    end  
    
    @recordings = current_recordings  
    
  end
  
  def showinfo  
    sch = Schedule.find params[:id]        
    back = { "schedule" => sch, "program" => sch.program }
    
    recording = Recording.find :all, :conditions => ["program_id = ?", sch.program_id]
    if recording.length > 0
      back[:recording] = recording[0]
    end
    
    render_json back.to_json
  end
  
  def othertimes_simpler
    sch = Schedule.find params[:id]
    recording = Recording.find :all, :conditions => ["program_id = ?", sch.program_id]

    prog = sch.program
    when_on = []    
    now = Time.new.utc
    cond = ['id != ? and ((start_time > ?) or ((start_time + (duration || \' minutes\')::interval) > ?))', sch.id, now, now]
    prog.schedules.find(:all, :conditions => cond, :order => 'start_time, station_id').each do |s|
      when_on[when_on.length] = { "id" => s.id, "when" => s.start_time, "on" => s.station.channels[0].channel, "hdtv" => s.hdtv, "recording" => (recording.length != 0 and recording[0].schedule_id == s.id) }
    end
    back = {"times" => when_on }
    render_json back.to_json
  end
  
  def err_json(msg, code)
    b = {"msg" => msg, "code" => code, "error" => true}
    render_json b.to_json
  end
  
  def fillin_data
    
    err_json("Hours is inavlid", -100) and return if params[:hours].nil? or params[:hours].to_i == 0
    err_json("Start is inavlid", -100) and return if params[:start].nil?
    
    sql = '(start_time between ? and ?)'
    
    unless params[:includecurrent].nil?
      sql = '((start_time between ? and ?) or start_time < ? and (start_time + (duration || \' minutes\')::interval) > ?)'
    end
    
    # find start of hour
    base_time = Time.parse(params[:start])
    hours_to_get = params[:hours].to_i.hours
    
    base_time = base_time - (base_time.sec).seconds
        
    start_time = base_time
    end_time = start_time + hours_to_get - 1.second
    
    start_time.utc
    end_time.utc
    
    conditions = [sql, start_time, end_time]
    unless params[:includecurrent].nil?
       conditions = [sql, start_time, end_time, start_time, start_time]
     end
    
    on = Schedule.find(:all, :conditions => conditions, :order => 'station_id, start_time')

    @on_array = []
    @prog_id_array = []
    on.each do |t|
      if(@on_array[t.station_id].nil?)
        @on_array[t.station_id] = []
      end
      @on_array[t.station_id][@on_array[t.station_id].length] = t
      @prog_id_array[@prog_id_array.length] = t.program_id
    end
    
    progs = Program.find(:all, :conditions => ['id in (?)', @prog_id_array])
    @progs_array = []
    progs.each do |t|
      @progs_array[t.id] = t
    end
    
    
    @zero_time = start_time
    @end_time = end_time.localtime
    start_time.localtime
    display_time_start = start_time
    display_time_stop = display_time_start + hours_to_get    
    @times_on_display = []
    while display_time_start < display_time_stop do
      @times_on_display[@times_on_display.length] = display_time_start
      display_time_start = display_time_start + 30.minutes
    end
    
    
    @recordings = current_recordings  
    
    out_channels = []
    @channels = Channel.find(:all, :order => :channel)
    @channels.each do |ch|
      
      this_programs = []
      unless  @on_array[ch.station_id].nil?
        @on_array[ch.station_id].each do |sch|
          
        	show_name = @progs_array[sch.program_id].title 
        	if(/Guthy|Paid/.match(show_name))
        		show_name = ""
        	end
        	
          this_programs[this_programs.length] = {
            "start_time" => sch.start_time,
            "duration" => sch.duration,
            "show_name" => show_name,
            "hdtv" => sch.hdtv,
            "first_run" => sch.first_run,
            "id" => sch.id,
            'recording' => !@recordings[sch.program_id].nil?,
            'program' => sch.program_id
          }
        end
      end
  
      this_channel = { "channel" => ch.id, "programs" => this_programs }
      
      out_channels[out_channels.length] = this_channel
      
    end
    
    back = { "display_times" => @times_on_display, "programs" => out_channels }
    
    render_json back.to_json
    
  end
  
  def channel_listing
    channels = Channel.find(:all, :order => :channel)
    
    stations = Station.find :all
    station_array = []
    stations.each do |t|
      station_array[t.id] = t
    end
    
    this_channels = []
    channels.each do |ch|
      this_channels[this_channels.length] = {
        "id" => ch.id,
        "num" => ch.channel,
        "station" => station_array[ch.station_id].call_sign,
        "station_name" => station_array[ch.station_id].name
      }
    end
    
    back = { "channels" => this_channels }
    render_json back.to_json
  end
  
end
