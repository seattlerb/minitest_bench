############################################################
# shoulda

require 'minitest/bench/minitest'

def shoulda_header type
  ['require "test/unit"',
  'require "shoulda"',
  "",
  "class TestShoulda#{type.capitalize} < Test::Unit::TestCase",
  "  context 'Shoulda#{type.capitalize}' do",
  "    setup do",
  "      @x = rand 1",
  "    end"].join("\n")
end

alias :shoulda_test :minitestunit_test

def shoulda_testcase n, type
  ["    should 'test #{"%04d" % n}' do",
   "      #{shoulda_test type}",
   "    end"].join("\n")
end

def shoulda_footer
  ["  end",
   "end"].join("\n")
end

$frameworks << "shoulda"
