#!/usr/bin/env ruby
require 'awesome_print'
require 'mail'
Dir[File.join(File.dirname(__FILE__), 'lib', '**', '*.rb')].each { |f| require f }

def grab_output
  tmp_out = $stdout
  begin
    buf = ''
    $stdout = StringIO.new(buf, 'w')
    yield
    return buf
  ensure
    $stdout = tmp_out
  end
end

email_content = grab_output do
  ap FlightDeals.specials_to(*ARGV), :plain => true
end

Mail.deliver do
  from 'Flight Deals <janaz@janaz.pl>'
  to 'janaz9@gmail.com'
  subject "Flight Deals for #{ARGV.join(',')}"
  delivery_method :sendmail
  text_part do
    body email_content
  end

  html_part do
    content_type 'text/html; charset=UTF-8'
    body "<pre style='font-size: 13px;'>\n#{email_content}\n</pre>\n"
  end
end
