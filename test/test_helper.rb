# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')

class RedminePirateHelpdeskTestCase < ActiveSupport::TestCase
  # stolen from redmine_dmsf
  # Allow us to override the fixtures method to implement fixtures for our plugin.
  # Ultimately it allows for better integration without blowing redmine fixtures up,
  # and allowing us to suppliment redmine fixtures if we need to.
  def self.fixtures(*table_names)
    dir = File.expand_path( File.dirname(__FILE__) +  "/fixtures" )
    puts dir
    table_names.each{|x,i|
      ActiveRecord::Fixtures.create_fixtures(dir, x) if File.exist?(dir + "/" + x.to_s + ".yml")
      puts "created fixture #{x}, #{i}"
    }
    super(table_names)
  end
end
