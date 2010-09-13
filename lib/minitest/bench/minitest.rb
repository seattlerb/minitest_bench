############################################################
# minitest/unit

def minitestunit_header type
  ['require "minitest/autorun"',
   "",
   "class MiniTestUnit#{type.capitalize} < MiniTest::Unit::TestCase",
   "  def setup",
   "    @x = rand 1",
   "  end"].join("\n")
end

def minitestunit_test type
  {
    "positive" => "assert_equal 0, @x",
    "negative" => "assert_equal 1, @x",
  }[type] or raise "unknown type: #{type.inspect}"
end

def minitestunit_testcase n, type
  ["  def test_#{"%04d" % n}",
   "    #{minitestunit_test type}",
   "  end"].join("\n")
end

def minitestunit_footer
  "end"
end

############################################################
# minitest/spec

def minitestspec_header type
  ['require "minitest/autorun"',
   "",
   "describe 'MinitestSpec#{type.capitalize}' do",
   "  before do",
   "    @x = rand 1",
   "  end" ].join("\n")
end

def minitestspec_test type
  case type
  when "positive" then
    "@x.must_equal 0"
  when "negative" then
    "@x.must_equal 1"
  else
    raise "unknown type: #{type.inspect}"
  end
end

def minitestspec_testcase n, type
  ["  it 'test_#{"%04d" % n}' do",
   "    #{minitestspec_test type}",
   "  end"].join("\n")
end

alias :minitestspec_footer :minitestunit_footer

$frameworks << "minitestunit" << "minitestspec"
