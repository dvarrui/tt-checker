#!/usr/bin/ruby
# encoding: utf-8

require 'rubygems'
require 'singleton'
require 'yaml'

require_relative 'case'
require_relative 'utils'
require_relative 'report/report'

class Teacher
	include Singleton
	include Utils
	attr_reader :global, :report, :tests
	
	def initialize
		@global = {}
		@report = Report.new
		@cases = []		
		@debug = false
		@verbose = true
		@tests=[]
	end
		
	def check_cases!(pConfigFilename = File.join(File.dirname($0),File.basename($0,".rb")+".yaml") )
		execute('clear')
		
		#Load cases from yaml config file
		configdata = YAML::load(File.open(pConfigFilename))
		@global = configdata[:global] || {}
		@global[:tt_testname]= @global[:tt_testname] || File.basename($0,".rb")
		@global[:tt_sequence]=false if @global[:tt_sequence].nil? 
		@caseConfigList = configdata[:cases]

		#Create out dir
		@outdir = @global[:tt_outdir] || File.join("var",@global[:tt_testname],"out")
		ensure_dir @outdir
		@report.outdir=@outdir

		#Fill report head
		@report.head[:tt_title]="Executing Teacher tests (version 0.2)"
		@report.head[:tt_scriptname]=$0
		@report.head[:tt_configfile]=pConfigFilename
		@report.head[:tt_debug]=true if @debug
		@report.head[:tt_start_time_]=Time.new.to_s
		@report.head.merge!(@global)
		
		bar = "="*@report.head[:tt_title].length
		verboseln bar
		verboseln @report.head[:tt_title]

		@caseConfigList.each { |lCaseConfig| @cases << Case.new(lCaseConfig) } # create cases
		start_time = Time.now
		if @global[:tt_sequence] then
			verboseln "[INFO] Running in sequence (#{start_time.to_s})"
			
			@cases.each { |c| c.start }
		else
			verboseln "[INFO] Running in parallel (#{start_time.to_s})"
			threads=[]
			@cases.each { |c| threads << Thread.new{c.start} }
			threads.each { |t| t.join }
		end
		finish_time=Time.now
		verboseln "\n[INFO] Duration = #{(finish_time-start_time).to_s} (#{finish_time.to_s})"

		verboseln "\n"
		verboseln bar
		
		@report.close
	end
	
	def debug=(pValue)
		@debug=pValue
	end
	
	def is_debug?
		@debug
	end
	
	def is_verbose?
		@verbose
	end

	def define_test(name, &block)
		@tests << { :name => name, :block => block }
	end
	
	def start(&block)
		check_cases!
		instance_eval &block
	end
end


def define_test(name, &block)
	Teacher.instance.define_test(name, &block)
end

def start(&block)
	Teacher.instance.start(&block)
end

