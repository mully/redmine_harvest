# Load the normal Rails helper
require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
require 'shoulda'
require 'fakeweb'
require 'vendor/plugins/redmine_harvest/test/blueprints.rb'
 
# Ensure that we are using the temporary fixture path
Engines::Testing.set_fixture_path

FakeWeb.allow_net_connect = false

class Test::Unit::TestCase
end

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

def stub_get(url, filename, status=nil)
  options = {:body => fixture_file(filename)}
  options.merge!({:status => status}) unless status.nil?  
  FakeWeb.register_uri(:get, url, options)
end

def stub_post(url, filename)
  FakeWeb.register_uri(:post, url, :body => fixture_file(filename))
end
