# -*- ruby -*-

abort "use rake19 stupid" if RUBY_VERSION < "1.9"

$: << 'lib'

require 'rubygems'
require 'hoe'

Hoe.plugin :isolate
# can't load minitest early
# Hoe.plugin :seattlerb
# instead:
Hoe.plugin :perforce, :email

class HashHash < Hash
  def initialize
    super { |h,k| h[k] = HashHash.new }
  end
end

Hoe.spec 'minitest_bench' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  self.version = "1.0.0"

  dependency "minitest",  "~> 4.0"
  dependency "rspec",     "~> 2.0"
  dependency "test-unit", "~> 2.0"
  dependency "bacon",     "~> 1.0"
  dependency "shoulda",   "~> 3.0"
  dependency "cucumber",  "~> 1.0"

  multiruby_skip << "1.8" << "1.9"
end

task :run => [:isolate, :generate, :bench, :report]

def test_file path
  out = "#{path}.out"
  file path        do |t| generate t end
  file out => path do |t| run_test t end
  task :clean      do rm_f [path, out] end
  task :generate => path
  task :bench    => out
end

task :rspec_wtf => :isolate do
  ENV["PATH"] = "tmp/isolate/ruby-1.9.1/bin:#{ENV["PATH"]}"

  puts "POSITIVE"
  puts
  [10, 100, 1_000, 10_000].each do |n|
    sh "X=1 /usr/bin/time -l #{Gem.ruby} -S rspec test/rspec_positive_#{n}.rb > /dev/null; true"
  end

  puts
  puts "NEGATIVE"
  puts

  [10, 100, 1_000, 10_000].each do |n|
    sh "X=1 /usr/bin/time -l #{Gem.ruby} -S rspec test/rspec_negative_#{n}.rb > /dev/null; true"
  end
end

$units      = [1, 10, 100, 1_000, 10_000]
$types      = %w(positive negative)
$frameworks = []

task :startup => [:isolate, :generate] do
  times = {}
  n = 100

  Dir["test/*positive_1.rb"].each do |path|
    framework, type, size = test_type path
    $stderr.puts framework
    t0 = Time.now
    n.times do
      system run_cmd(path)
    end
    t1 = Time.now
    t = t1 - t0

    times[framework] = [t, t / n]
  end

  puts "N = #{n}"
  puts
  times.sort_by { |f,(tt, tp)| tp }.each do |f,(tt, tp)|
    puts "%-12s: %6.2f s (%.2f s / run)" % [f, tt, tp]
  end
end

task :trace => :generate do
  Dir["test/*positive_1.*"].each do |path|
    framework, type, size = test_type path
    $stderr.puts framework
    system trace_cmd(path)
  end
end

Gem.find_files("minitest/bench/*.rb").each do |path|
  require path
end

# $types.delete "negative"

$units.each do |n|
  $types.each do |type|
    $frameworks.each do |framework|
      if respond_to? "#{framework}_task" then
        send "#{framework}_task", framework, type, n
      else
        test_file "test/#{framework}_#{type}_#{n}.rb"
      end
    end
  end
end

task :report do
  reports = {}
  sreports = {}

  $units.each do |n|
    treport = Hash.new { |h,k| h[k] = {} } # time
    sreport = Hash.new { |h,k| h[k] = {} } # size

    Dir["test/*_#{n}.*.out"].sort.each do |path|
      framework, type, size = test_type path.sub(/\.out$/, '')

      # /usr/bin/time -l output:
      #       0.08 real         0.05 user         0.01 sys
      # 46874624  maximum resident set size
      # ...

      output = `tail -15 #{path}`
      time = output[/\d+\.\d+ real/].to_f
      size = output[/\d+  maximum resident set size/].to_i

      p [path, time, size]

      treport[framework][type] = time
      sreport[framework][type] = size
    end

    min_p = treport.map { |k,v| v["positive"] }.min
    min_n = treport.map { |k,v| v["negative"] }.min
    max_p = treport.map { |k,v| v["positive"] }.max
    max_n = treport.map { |k,v| v["negative"] }.max

    treport.each do |framework, h|
      p_x = h["positive"] / min_p
      n_x = h["negative"] / min_n

      h["positive_x"] = p_x
      h["negative_x"] = n_x
      h["avg_x"]      = (p_x + n_x) / 2
    end

    reports[n] = treport
    sreports[n] = sreport

    treport = treport.sort_by { |k,h| h["avg_x"] }

    cols = %w( positive positive_x negative negative_x avg_x)

    num = treport.map { |k,h| [k, *h.values_at(*cols)] }.transpose
    num.shift # projects
    records = Hash.new { |h,k| h[k] = {} }
    cols.zip(num).each do |k, a|
      records[k][a.min] = "best"
      records[k][a.max] = "worst"
    end

    format = ['<tr><th>%s</th>',
              '<td class="n %s">%.2f</td><td class="x %s">(%.2f x)</td>',
              '<td class="n %s">%.2f</td><td class="x %s">(%.2f x)</td>',
              '<td class="x %s">(%.2f x)</td></tr>'].join

    File.open "report.#{n}.html", "w" do |f|
      f.puts '<?xml version="1.0" encoding="utf-8"?>'
      f.puts '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" '
      f.puts '   "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
      f.puts '<html xmlns="http://www.w3.org/1999/xhtml">'
      f.puts '<head>'
      f.puts "<title>Test Framework Benchmark (iter = #{n})</title>"
      f.puts '<style>'
      f.puts 'th   { text-align: right; }'
      f.puts 'td   { text-align: right; background-color: #eee; }'
      f.puts 'td.best  { background-color: #9f9; }'
      f.puts 'td.worst { background-color: #f99; }'
      f.puts '</style>'
      f.puts '</head>'
      f.puts '<body>'
      f.puts '<table>'
      f.puts "<tr><th>framework</th><th>pos (s)</th><th>multiple</th><th>neg (s)</th><th>multiple</th><th>avg</th></tr>"
      treport.sort_by { |k,h| h["avg_x"] }.each do |framework, h|
        v = h.values_at(*cols)
        a = cols.map { |col| records[col][h[col]] }
        f.puts format % [framework, *a.zip(v).flatten]
      end
      f.puts "</table>"
    end
  end

  puts "Times:"
  puts

  xxx = HashHash.new
  reports.each do |num, rep|
    rep.each do |framework, result|
      result.each do |k,v|
        next if k =~ /_x$/
        xxx[k][framework][num] = v
      end
    end
  end

  $types.each do |type|
    frameworks = xxx[type]
    puts "#{type}\t#{$units.join("\t")}"
    frameworks.sort_by { |_, ts| ts.sort[-1][-1] }.each do |framework, units|
      times = units.sort.map { |k,v| v }
      puts "%-12s\t%s" % [framework, times.join("\t")]
    end
    puts
  end

  yyy = HashHash.new
  sreports.each do |num, rep|
    rep.each do |framework, result|
      result.each do |k,v|
        next if k =~ /_x$/
        yyy[k][framework][num] = v
      end
    end
  end

  puts "Sizes (RSS in MB):"
  puts

  $types.each do |type|
    frameworks = yyy[type]
    puts "#{type}\t#{$units.join("\t")}"
    frameworks.sort_by { |_, ts| ts.sort[-1][-1] }.each do |framework, units|
      times = units.sort.map { |k,v| v.to_f / (1024 * 1024) }
      puts "%-12s\t%.2f\t%.2f\t%.2f\t%.2f\t%.2f" % [framework, *times]
    end
    puts
  end
end

############################################################
# support

def test_type path
  File.basename(path).sub(/\.(rb|feature)$/, '').split(/_/)
end

def generate t
  path = t.name
  framework, type, size = test_type path

  if respond_to? "generate_#{framework}" then
    send "generate_#{framework}", path, framework, type, size
  else
    mkdir_p File.dirname(path)
    generic_generate path, framework, type, size
  end
end

def generic_generate path, framework, type, size
  File.open path, "w" do |f|
    f.puts send "#{framework}_header", type
    f.puts
    size.to_i.times do |n|
      f.puts send "#{framework}_testcase", n, type
      f.puts
    end

    f.puts send "#{framework}_footer"
  end
end

def run_cmd path, out = "/dev/null"
  framework, type, size = test_type path

  cmd = case framework
        when "minitestunit", "minitestspec", "testunit2", "shoulda" then
          "-rubygems"
        when "testunit1" then
          "-rubygems"
        when "rspec1" then
          "-S spec"
        when "rspec" then
          "-S rspec"
        when "bacon" then
          "-S bacon"
        when "cucumber" then
          "-S cucumber --no-color -f progress --require test/cucumber.rb"
        else
          raise "unknown framework: #{framework.inspect}"
        end

  "X=1 /usr/bin/time -l #{Gem.ruby} #{cmd} #{path} &> #{out}; true"
end

def trace_cmd path
  framework, type, size = test_type path

  out = "trace/#{framework}_trace.txt"

  cmd = case framework
        when "minitestunit", "minitestspec", "testunit2", "shoulda" then
          "-rubygems -rtracer"
        when "testunit1" then
          "-rubygems -rtracer"
        when "rspec1" then
          "-rtracer -S spec"
        when "rspec" then
          "-rtracer -S rspec"
        when "bacon" then
          "-rtracer -S bacon"
        when "cucumber" then
          "-rtracer -S cucumber --no-color -f progress --require test/cucumber.rb"
        else
          raise "unknown framework: #{framework.inspect}"
        end

  "X=1 time #{Gem.ruby} #{cmd} #{path} 2>&1 | grep -v rubygems > #{out}; true"
end

def run_test t
  out  = t.name
  path = t.prerequisites.first

  sh run_cmd(path, out)
end

# vim: syntax=ruby
