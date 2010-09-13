############################################################
# bacon

require 'minitest/bench/minitest'

def bacon_header type
  ["require 'bacon'",
   "",
   "describe 'Bacon#{type.capitalize}' do",
   "  before do",
   "    @x = rand 1",
   "  end"].join("\n")
end

def bacon_test type
  case type
  when "positive" then
    "@x.should.equal 0"
  when "negative" then
    "@x.should.equal 1"
  else
    raise "unknown type: #{type.inspect}"
  end
end

def bacon_testcase n, type
  ["  it 'test #{"%04d" % n}' do",
   "    #{bacon_test type}",
   "  end"].join("\n")
end

alias :bacon_footer :minitestunit_footer

$frameworks << "bacon"
