# -*- ruby -*-

$: << 'lib'

require 'rubygems'
require 'hoe'

Hoe.plugin :isolate
Hoe.plugin :seattlerb

class HashHash < Hash
  def initialize
    super { |h,k| h[k] = HashHash.new }
  end
end

Hoe.spec 'minitest_bench' do
  developer 'Ryan Davis', 'ryand-ruby@zenspider.com'

  self.version = "1.0.0"
  self.rubyforge_name = 'seattlerb'

  extra_deps << ["ZenTest",   "> 0"]
  extra_deps << ["minitest",  "> 0"]
  extra_deps << ["rspec",     "> 0"]
  extra_deps << ["test-unit", "> 0"]
  extra_deps << ["bacon",     "> 0"]
  extra_deps << ["shoulda",   "> 0"]
  extra_deps << ["cucumber",  "> 0"]
end

task :run => [:generate, :bench, :report]

def test_file path
  out = "#{path}.out"
  file path        do |t| generate t end
  file out => path do |t| run_test t end
  task :clean      do rm_f [path, out] end
  task :generate => path
  task :bench    => out
end

$units      = [1, 10, 100, 1_000, 10_000]
$types      = %w(positive negative)
$frameworks = []

task :startup => :generate do
  times = {}
  n = 100

  Dir["test/*positive_1.*"].each do |path|
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

Gem.find_files("minitest/bench/*.rb").each do |path|
  require path
end

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

  $units.each do |n|
    report = Hash.new { |h,k| h[k] = {} }

    Dir["test/*_#{n}.*.out"].sort.each do |path|
      framework, type, size = test_type path.sub(/\.out$/, '')
      report[framework][type] = `tail -1 #{path}`.to_f
    end

    min_p = report.map { |k,v| v["positive"] }.min
    min_n = report.map { |k,v| v["negative"] }.min
    max_p = report.map { |k,v| v["positive"] }.max
    max_n = report.map { |k,v| v["negative"] }.max

    report.each do |framework, h|
      p_x = h["positive"] / min_p
      n_x = h["negative"] / min_n

      h["positive_x"] = p_x
      h["negative_x"] = n_x
      h["avg_x"]      = (p_x + n_x) / 2
    end

    reports[n] = report

    report = report.sort_by { |k,h| h["avg_x"] }

    cols = %w( positive positive_x negative negative_x avg_x)

    num = report.map { |k,h| [k, *h.values_at(*cols)] }.transpose
    num.shift # projects
    records = Hash.new { |h,k| h[k] = {} }
    cols.zip(num).each do |k, a|
      records[k][a.min] = "best"
      records[k][a.max] = "worst"
    end

    xxx = HashHash.new
    reports.each do |num, rep|
      rep.each do |framework, result|
        result.each do |k,v|
          next if k =~ /_x$/
          xxx[k][framework][num] = v
        end
      end
    end

    xxx.each do |type, frameworks|
      p :type => type
      frameworks.sort.each do |framework, units|
        times = units.sort.map { |k,v| v }
        puts "#{framework}\t#{times.join("\t")}"
      end
      puts
    end

    # puts "Size = #{n}:"
    # puts "%15s: %6s (%8s) %6s (%8s) (%8s)" %
    #   %w(framework pos multiple neg multiple avg)
    # puts "-" * 63
    # report.each do |framework, h|
    #   puts "%15s: %6.2f (%6.2f x) %6.2f (%6.2f x) (%6.2f x)" %
    #     [framework, *h.values_at(*cols)]
    # end

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
      report.sort_by { |k,h| h["avg_x"] }.each do |framework, h|
        v = h.values_at(*cols)
        a = cols.map { |col| records[col][h[col]] }
        f.puts format % [framework, *a.zip(v).flatten]
      end
      f.puts "</table>"
    end
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
          "ruby -rubygems"
        when "testunit1" then
          "ruby -rubygems"
        when "rspec" then
          "spec"
        when "bacon" then
          "bacon"
        when "cucumber" then
          "cucumber --no-color -f progress --require test/cucumber.rb"
        else
          raise "unknown framework: #{framework.inspect}"
        end

  "X=1 time #{cmd} #{path} &> #{out}; true"
end

def run_test t
  out  = t.name
  path = t.prerequisites.first

  sh run_cmd(path, out)
end

# vim: syntax=ruby
