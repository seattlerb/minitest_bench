############################################################
# rspec

require 'minitest/bench/minitest'

def rspec_header type
  ["describe 'Rspec#{type.capitalize}' do",
  "  before :each do",
  "    @x = rand 1",
  "  end"].join("\n")
end

def rspec_test type
  case type
  when "positive" then
    "@x.should == 0"
  when "negative" then
    "@x.should == 1"
  else
    raise "unknown type: #{type.inspect}"
  end
end

def rspec_testcase n, type
  ["  it 'test #{"%04d" % n}' do",
   "    #{rspec_test type}",
   "  end"].join("\n")
end

alias :rspec_footer :minitestunit_footer

# unfortunately, the way the setup currently works, you can't run
# these both side by side, yet.
$frameworks << "rspec" # << "rspec1"
