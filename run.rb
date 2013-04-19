#!/usr/bin/env ruby
require 'ap'
Dir[File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')].each {|f| require f} 
ap FlightDeals.specials_to(*ARGV)
