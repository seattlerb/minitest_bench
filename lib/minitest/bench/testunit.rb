############################################################
# test-unit 1 & 2

require 'minitest/bench/minitest'

def testunit1_header type
  ['require "test/unit"',
  "",
  "class TestUnit1#{type.capitalize} < Test::Unit::TestCase",
  "  def setup",
  "    @x = rand 1",
  "  end"].join("\n")
end

alias :testunit1_testcase   :minitestunit_testcase
alias :testunit1_footer :minitestunit_footer

def testunit2_header type
  "gem 'test-unit'\n\n" + testunit1_header(type)
end

alias :testunit2_testcase   :testunit1_testcase
alias :testunit2_footer :testunit1_footer

$frameworks << "testunit1" << "testunit2"
