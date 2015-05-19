require 'rubygems'

require File.join(__dir__, '..', 'app', 'mail_forwarder.rb')

begin
  MailForwarder.run
rescue
end
