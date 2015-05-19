require 'minitest/autorun'
require 'rubygems'
require 'bundler/setup'
require 'mail'
require 'pry'
require 'yaml'

require File.dirname(__FILE__) + '/../app/mail_receiver.rb'

describe MailReceiver do
  before do
    @properties = YAML.load_file(File.dirname(__FILE__) + "/../config/properties.yml")
  end
  
  after do
    Mail::TestMailer.deliveries.clear
  end

  describe "mail receiver run" do
    describe "to whitelist" do
      before do
        ARGV.replace [File.dirname(__FILE__) + "/fixtures/email.txt"]
        MailReceiver.run
      end
      
      it "delivers mail" do
        assert_equal(Mail::TestMailer.deliveries.length, 1)
      end
    
      it "changes recipient " do
        assert_equal(Mail::TestMailer.deliveries.first.to, [@properties['recipient']])
      end
    end
    
    describe "not to whitelist" do
      before do
        ARGV.replace [File.dirname(__FILE__) + "/fixtures/email_bad_recipient.txt"]
        MailReceiver.run
      end

      it "doesn't deliver mail" do
        assert_equal(Mail::TestMailer.deliveries.length, 0)
      end
    end

    describe "from blacklist" do
      before do
        ARGV.replace [File.dirname(__FILE__) + "/fixtures/email_bad_sender.txt"]
        MailReceiver.run
      end

      it "doesn't deliver mail" do
        assert_equal(Mail::TestMailer.deliveries.length, 0)
      end
    end
  end
end