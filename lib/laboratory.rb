
require 'terminal-table'
require_relative 'application'
require_relative 'case/result'

def task(name, &block)
  Application.instance.tasks << { :name => name, :block => block }
end

def start(&block)
  #don't do nothing
end


class Laboratory
  attr_reader :result
  
  def initialize(pathtofile)
    @path={}
    @path[:script]   = pathtofile
    @path[:dirname]  = File.dirname(pathtofile)
    @path[:filename] = File.basename( pathtofile, ".rb")
    @path[:config]   = File.join( @path[:dirname], @path[:filename]+".yaml" )
    
    @result = Result.new
    @targetid=0
    @stats={ :tasks => 0, :targets => 0, :uniques => 0, :gets => 0, :logs => 0}
    @gets={}
    @hosts={}
  end
  
  def whatihavetodo
    @tasks = Application.instance.tasks
    puts ""
    @tasks.each do |t|
      @stats[:tasks]+=1
      
      msg ="TASK: #{t[:name]}"
      my_screen_table = Terminal::Table.new { |st| st.add_row [ msg ] } 
      puts my_screen_table
      
      instance_eval &t[:block]
    end
    
    show_stats
  end
    
  def target(description="empty")
    @stats[:targets]+=1
    
    @targetid+=1
    i=@targetid
    puts "(%03d"%i+") target #{description}"
  end

  def goto(pHost=:localhost, pArgs={})
    result.reset
    h=pHost.to_s
    h=":#{h}" if pHost.class==Symbol

    if @hosts[h] 
      @hosts[h]+=1
    else
      @hosts[h]=1
    end
    puts "      goto   #{h} and #{pArgs.to_s}"
  end
  
  def expect(pCond, pArgs={})
    weight=1.0
    weight=pArgs[:weight].to_f if pArgs[:weight]
    puts "      alter  #{result.alterations}" if result.alterations.size>0
    puts "      expect #{result.expected} (#{result.expected.class.to_s})"
    puts "      weight #{weight.to_s}"
    puts ""
  end
  
  def get(varname)
    @stats[:gets]+=1
    
    v=varname.to_s
    v=":#{v}" if varname.class==Symbol
    
    if @gets[v]
      @gets[v]+=1
    else
      @gets[v]=1
    end
    
    return "get(#{v})"
  end
  
  def unique(key,value)
    @stats[:uniques]+=1
    
    puts "    ! Unique value for <#{key.to_s}>"
    puts ""
  end

  def log(text="", type=:info)
    @stats[:logs]+=1
  end
    
  def show_stats
    @stats[:hosts]=0
    @hosts.each_pair { |k,v| @stats[:hosts]+=v }
    
    my_screen_table = Terminal::Table.new do |st|
      st.add_row [ "DSL Stats"  , "Count"] 
      st.add_separator
      st.add_row [ "Tasks"  , @stats[:tasks]] 
      st.add_row [ "Targets", @stats[:targets]] 
      st.add_row [ "Goto"  , @stats[:hosts]] 
      @hosts.each_pair { |k,v| st.add_row [ " * #{k}", v] } 
      st.add_row [ "Uniques", @stats[:uniques]] 
      st.add_row [ "Logs"   , @stats[:uniques]] 
      st.add_row [ " "      , " " ] 
      st.add_row [ "Gets"   , @stats[:gets]] 

      if @gets.count>0
        list=@gets.sort_by { |k,v| v}
        list.reverse.each { |item|  st.add_row [ " * #{item[0]}"  , item[1].to_s] }
      end 
    end
    puts my_screen_table.to_s+"\n"    
  end
  
end
