############################################################
# cucumber
# from cucumber/examples/test-unit

public # to prevent global defs from being private and not seen by respond_to?

def cucumber_task framework, type, n
  test_file "test/cucumber_#{type}_#{n}.feature"
  task :clean do rm_f "test/cucumber.rb" end
end

def generate_cucumber path, framework, type, size
  c_path = "test/cucumber.rb"
  File.open c_path, "w" do |f|
    f.puts <<-'EOM'.gsub(/^      /, '')
      require 'test/unit/assertions'
      World(Test::Unit::Assertions)

      Given /^(\w+) = rand (\d+)$/ do |var, value|
        instance_variable_set("@#{var}", rand(value.to_i))
      end

      Then /^I can assert that (\d+) == (\w+)$/ do |n, var|
        assert_equal(n.to_i, instance_variable_get("@#{var}"))
      end
    EOM
  end unless File.exist? c_path

  generic_generate path, framework, type, size
end

def cucumber_header type
  "Feature: Cucumber#{type.capitalize}
  In order to please people who like Test::Unit
  As a Cucumber user
  I want to be able to use assert* in my step definitions"
end

def cucumber_test type
  {
    "positive" => "Then I can assert that 0 == x",
    "negative" => "Then I can assert that 1 == x",
  }[type] or raise "Unknown type #{type.inspect}"
end

def cucumber_testcase n, type
  "  Scenario: cucumber #{'%04d' % n}
    Given x = rand 1
    #{cucumber_test type}"
end

def cucumber_footer
  ""
end

$frameworks << "cucumber"
