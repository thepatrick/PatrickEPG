require 'open-uri'
require 'cgi'
require 'rexml/document'
require 'date'
require 'fileutils'

class TvrageCache < ActiveRecord::Base
  establish_connection(:adapter => "postgresql", :database => "#",
      :host => "localhost", :port => 5432, :username => '#');
end

class EncoderController < ApplicationController
  
  def disk_space
    back = { :working => free_disk_space("/"), :store => free_disk_space("/path/to/where/the/encoder/looks") }
    render_json back.to_json
  end
  
  def free_disk_space(path)
    ds = `df -k "#{path}"`.scan(/\s([0-9]+)\s+([0-9]+)\s+([0-9]+)\s+([0-9]+)\%/)[0]        
    {
      :size => ds[0].to_i,
      :used => ds[1].to_i,
      :available => ds[2].to_i,
      :capacity => ds[3].to_i,
    }
  end

  def queue
    
    files, encoding_now_file = folder_listing('/path/to/where/the/encoder/looks/')
    
    pqd = '/path/to/where/the/pvr/saves/'
    back = { :progress => encoding_now(encoding_now_file), :pending => pending_queue_length(pqd) } 
    
    back[:queue] = files if params[:progress].nil?
    
    render_json back.to_json
    
  end
  
  def pending_queue_length(dir)
    back = 0
    Dir.open(dir).each do |file|
      if file.to_s.scan(/\.m2t$/).length > 0
        back = back + 1
      end
    end
    back
  end
  
  def folder_listing(dir)

    encoding_file = nil
    back = []
    Dir.open(dir).each do |file|

      if file.to_s.scan(/\.m2t$/).length > 0
        v = file.to_s.scan(/(.*)\.m2t/)[0][0]

        ex = File.exists?(dir + v + '.m4v')
        log = File.exists?(dir + file.to_s + ".log")      
        
        encoding = ex && log
        copying = ex && !log 

        encoding_file = dir + file if encoding    
        
        unless encoding
          
          name = v.gsub(/\./, ' ')
          subline = ""
          movie = false
          if(name.scan(/(.*)MOVIE\s[^\.]+/)[0])
             name, subline = name.scan(/(.*)MOVIE\s([^\.]+)/)[0]
             movie = true
          elsif(name.scan(/(.*)S([0-9]+)E([0-9]+)/)[0])
             name, season, episode = name.scan(/(.*)S([0-9]+)E([0-9]+)/)[0]
             subline = "Season " + season.to_i.to_s + ", Episode " + episode.to_i.to_s
          end
          
          back[back.length] = {
            :copying => copying,
            :name => name.strip,
            :subline => subline.strip,
            :original => file,
            :movie => movie          
          }
        end
      end

    end

    [back, encoding_file]
  end
  
  def encoding_now(file)
    return { :inprogress => false } unless file
    
    progress_str = `tail -b 1 "#{file}.log" | tr "\r" "\n" | tail -n 1`.to_s

    # Encoding: task 1 of 1, 0.01 %
    # Encoding: task 1 of 1, 0.71 % (4.11 fps, avg 4.34 fps, ETA 02h51m04s)

    progress, x = progress_str.scan(/([0-9\.]+)\s\%(.*)?/)[0]

    unless x.nil?
      hours, minutes, seconds = x.scan(/ETA ([0-9]+)h([0-9]+)m([0-9]+)s/)[0]
    end

    time = ""
    unless hours.nil? or minutes.nil? or seconds.nil?
      time = hours.to_i.to_s + ":" + minutes + ":" + seconds
    end

    name = file.to_s.scan(/([^\/]+)\.m2t/)[0][0].gsub(/\./, ' ')
    subline = ""
    movie = false
    if(name.scan(/(.*)MOVIE\s[^\.]+/)[0])
      name, subline = name.scan(/(.*)MOVIE\s([^\.]+)/)[0]
      movie = true
    elsif(name.scan(/(.*)S([0-9]+)E([0-9]+)/)[0])
      name, season, episode = name.scan(/(.*)S([0-9]+)E([0-9]+)/)[0]
      subline = "Season " + season.to_i.to_s + ", Episode " + episode.to_i.to_s
    end
    
    {
      :inprogress => true,
      :name => name,
      :subline => subline,
      :movie => movie,
      :progress => progress.to_d,
      :remaining => time
    }
  end
  
  def waiting_item(file, where)
    v, episode, name = file.to_s.scan(/^(.*)\.PVREP ([^\.]+)?[\.]?(.*)\.m2t/)[0]

    mod = File.mtime(where + file).to_s
    
    {
      :name => v.gsub(/\./, ' '),
      :episode => episode,
      :epname => name,
      :modified => mod
    }
    
  end
  
  def waiting_list
    
    encoding_file = nil
    display_name = nil
    back = []

    dir = '/path/to/where/the/pvr/saves'
    Dir.open(dir).each do |file|
      if file.to_s.scan(/\.m2t$/).length > 0
        back[back.length] = waiting_item(file, dir)
      end
    end
    
    resp = { :list => back }
    
    render_json resp.to_json    
  end
  
  def get_tv_show(showname_clean)

  	tvshow = TvrageCache.find_or_create_by_showname(showname_clean)
  	if tvshow.tvrageid.nil?
      read_data = open("http://services.tvrage.com/feeds/search.php?show=" + CGI.escape(showname_clean)).read

      doc = REXML::Document.new(read_data)
      show_id, x = doc.root.elements['show/showid']
      unless show_id.nil?
        tvshow.tvrageid = show_id.text.to_i
      end

      tvshow.save
    end

    tvshow
  end
  
  def options(doc, season, name)

    tvr_season = doc.root.elements['Episodelist/Season[@no=' + season.to_s + ']']

    my_options = []
    tvr_season.elements.each('episode') do |ep|
      seasonnum = ep.elements['seasonnum'].text
      epnum = ep.elements['epnum'].text
      airdate = ep.elements['airdate'].text
      title = ep.elements['title'].text

      my_options[my_options.length] = {
        :value => 'S'+ season.to_s + 'E' + seasonnum,
        :title => seasonnum + ": " + title + ' ('+ airdate + ", " + epnum + ')',
        :likely => (name == title.gsub(/[\;\/\"\:]/,''))
      }
    end

    
    { :title => "Season " + season.to_s, :options => my_options.reverse }
  end
  
  def movie_options
    ep_chooser = []
    %w[Comedy Drama Family Music].each do |r|
      ep_chooser[ep_chooser.length] = { :value => 'MOVIE.'+r, :label => r}
    end  
    { :title => "Movies", :options => ep_chooser }    
  end
  
  def potentials
    
    tvshow = get_tv_show(params[:name])
    
    read_data = open("http://services.tvrage.com/feeds/episode_list.php?sid=" + tvshow.tvrageid.to_s).read
    doc = REXML::Document.new(read_data)
    if(tvshow.overridename.nil?)
      tvr_show_name = doc.root.elements['name']
      unless tvr_show_name.nil?
        showname_clean = tvr_show_name.text
      end
    else
      showname_clean = tvshow.overridename
    end
    
    name = params[:epname]
    
    tvr_seasons = doc.root.elements['totalseasons'].text.to_i
    
    my_options = []
    
    while(tvr_seasons > 0)
      my_options[my_options.length] = options(doc, tvr_seasons, name)
      tvr_seasons = tvr_seasons - 1
    end

    my_options[my_options.length] = movie_options    
    back = { :name => params[:name], :options => my_options }
    render_json back.to_json
  end
  
end
