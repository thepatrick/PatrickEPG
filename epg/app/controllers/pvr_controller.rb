class PvrController < ApplicationController
  
  def times_this_is_on(prog)
    when_on = []    
    now = Time.new.utc
    cond = ['(start_time > ?)', now]
    prog.schedules.find(:all, :conditions => cond, :order => 'start_time, station_id').each do |s|
      when_on[when_on.length] = { "id" => s.id, "duration" => s.duration, "when" => s.start_time, "on" => s.station.channels[0].channel, "hdtv" => s.hdtv }
    end
    return when_on
  end
  
  def find_best_time(r)
    
    s = Schedule.find_by_id r.schedule_id
    
    if(s)
      return s
    else
      # First, find out when it is on...
      times = times_this_is_on(r.program)
      return nil if times.length == 0
            
      # Prefer a higher channel... because these have HD :)
      best_channel = 0
      best_time = 0
      time_count = 0
      times.each do |t|
        time_count = time_count + 1
        if t['on'] > best_channel
          best_channel = t['on']
          best_time = t['id']
        end
      end
      
      # ok, so the best is: times[best_time].id
      
      return Schedule.find best_time
      
    end
  end
  
  def obt_hash(this_sch, r)
    return {
      'program_id' => this_sch.program_id,
      'schedule_id' => this_sch.id,
      'startTime' => this_sch.start_time,
      'duration' => this_sch.duration,
      'showName' => this_sch.program.title + ".PVREP " + this_sch.program.syndicated_episode_number.to_s + (this_sch.program.subtitle.nil? ? "" : "." + this_sch.program.subtitle.gsub(/[\;\/\"\:]/, "")),
      'episode' => this_sch.program.syndicated_episode_number,
      'channel' => this_sch.station.channels[0].channel,
      'status' => r.state,
      'id' => r.id
    }
  end
  
  def data
    cond = "state IN ('New', 'Recording')"
    recordings = Recording.find :all, :conditions => [cond]
    
    sch = []
    
    recordings.each do |r|
      sched = Schedule.find_by_id r.schedule_id
      if(r.state == 'Recording' and sched)
        sch[sch.length] = obt_hash sched, r
      else
        show = find_best_time r
        unless show.nil?
          sch[sch.length] = obt_hash show, r
        end    
      end
    end
    
    #sch[sch.length] = obt_hash Schedule.find(116479)
    
    b = {"recordings" => sch} #, "oldschool" => recordings}
    render_json b.to_json
    
  end
  
  def schedule
    s = Schedule.find params[:id]    
    r = Recording.new
    r.program_id = s.program_id
    r.schedule_id = s.id
    r.state = 'New'
    r.save
    back = { 'success' => true, 'recording' => obt_hash(s, r) }
    render_json back.to_json
  end
  
  def add_program
    r = Recording.new
    r.program_id = params[:id]
    r.state = 'New'
    r.save
    render_json r.to_json
  end
  
  def delete_program
    r = Recording.find params[:id]
    r.destroy
    back = { "recording" => r, "success" => true}
    render_json back.to_json
  end

  def update_status
    r = Recording.find params[:id]
    r.state = params[:status] unless params[:status].nil?
    r.save
    
    back = { 'recording:' => obt_hash(Schedule.find(r.schedule_id), r),
             'success' => true }
    render_json back.to_json    
  end
  
  def delete_program
    r = Recording.find params[:id]
    r.destroy
    back = { "recording" => r, "success" => true}
    render_json back.to_json
  end
  
  #http://epg.ca.patrick.geek.nz/PVR/Change.json?id=480&to=537843

  def change_recording
    r = Recording.find params[:id]
    s = Schedule.find params[:to]
    
    if(r.program_id != s.program_id)
      back = { 'recording' => obt_hash(Schedule.find(r.schedule_id), r),
               'success' => false }
    else 
      r.schedule_id = s.id
      r.save
      back = { 'recording' => obt_hash(s, r), 'success' => true }
    end    
    render_json back.to_json    
  end
  
end
