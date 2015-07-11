#!/home2/judykatc/ruby/bin/ruby -W0

require 'rubygems'

require File.join(__dir__, '..', 'app', 'mail_forwarder.rb')

File.open(File.join(__dir__, '..', 'log', 'mail_forwarder.log'), 'w') do |file|
  file.write("-- begin #{Time.now.to_s}")
  begin
    MailForwarder.run
  rescue => e
    file.write("ERROR #{e.message}\n#{e.backtrace}")
  end
  file.write("success #{Time.now.to_s}")
end