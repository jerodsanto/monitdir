#!/usr/bin/env ruby

# == Synopsis 
#   Monitors a directory at given interval for file additions/subtractions. 
#   When a file is added or removed it will either print said file or perform
#   an action as specified in command line arguments. Best run as daemon
#
# == Examples
#   monitDir.rb -d ~/Downloads -i 10 -r
#     
# == Usage 
#   monitDir.rb -d [directory to monitor] [options]
#
#   For help use: monitDir.rb -h
#
# == Options
#   -d, --directory     Directory to monitor (required)
#   -r, --recursive     Monitor subdirectories too (default = off)
#   -i, --interval      Time between polls, in seconds (default = 5)
#   -e, --execute       Command to execute when directory changes
#   -h, --help          Displays help message
#   -v, --version       Display the version, then exit
#
# == Author
#   Jerod Santo, jerod.santo@gmail.com, http://blog.jerodsanto.net
#
# == Copyright
#   Copyright (c) 2008 Jerod Santo. Licensed under the MIT License:
#   http://www.opensource.org/licenses/mit-license.php

require 'optparse' 
require 'rdoc/usage'
require 'ostruct'
require 'date'
require 'find'


class App
  VERSION = '0.1'

  attr_reader :options

  def initialize(arguments)
    @arguments = arguments

    #Set default options
    @options = OpenStruct.new
    @options.recursive = false
    @options.interval = 5
    @options.action = "print"
  end

  #Parse options, check arguments, then run the command
  def run
    if parsed_options?
      start_monitDir
    else
      output_usage
    end
  end
  
  protected
  
  def parsed_options?
    opts = OptionParser.new
    opts.on('-v', '--version')                { output_version; exit 0 }
    opts.on('-h', '--help')                   { output_options }
    opts.on('-r', '--recursive')              { @options.recursive = true }
    opts.on('-d', '--directory DIR', String)  { |@options.directory| }    
    opts.on('-i', '--interval INT', Integer)  { |@options.interval| }
    opts.on('-e', '--execute CMD', String)    { |@options.action| }
    
    opts.parse!(@arguments) rescue return false
    puts @options.interval
    return false unless !@options.directory.nil?
    true
  end
  
  def output_version
    puts "#{File.basename(__FILE__)} version #{VERSION}"
  end
  
  def output_usage
    RDoc::usage('usage') #derived from comments above
  end
  
  def output_options
    RDoc::usage('options')
  end
  
  def start_monitDir
    monit = MonitDir.new(@options.directory,@options.recursive)

    loop do
        monit.poll(@options.action)
      sleep @options.interval
    end
  end
  
  
end

class Snapshot
  attr_reader :time, :file_names

  def initialize(dir,recursive = false)
    @dir = Dir.open(File.expand_path(dir))
    @time = Time.now
    @file_names = Array.new
    if recursive
      Find.find(@dir.path) do |path|
        if FileTest.directory?(path)
          next
        else
          @file_names << path
        end
      end
    else
      @file_names  = @dir.collect
    end
  end

end

class MonitDir

  def initialize(dir,recursive = false)
    @dir = dir
    @recursive = recursive
    @previous = Snapshot.new(@dir,@recursive)
    @current = @previous
  end

  def poll(action)
    @current = Snapshot.new(@dir,@recursive)
    time_diff = @current.time - @previous.time

    if @current.file_names != @previous.file_names
      new_files = @current.file_names - @previous.file_names
      removed_files = @previous.file_names - @current.file_names
      if action == "print"
        new_files.each { |f| puts "new file: #{f}" } unless new_files.nil?
        removed_files.each { |f| puts "file removed: #{f}" } unless removed_files.nil?
      else
        system(action)
      end
    end

    @previous = @current
  end

end

app = App.new(ARGV)
app.run