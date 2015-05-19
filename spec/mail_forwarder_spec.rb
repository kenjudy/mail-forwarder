require 'minitest/autorun'
require 'rubygems'
require 'bundler/setup'
require 'mail'
require 'pry'
require 'yaml'

require File.join(__dir__, '..', 'app', 'mail_forwarder.rb')

describe MailForwarder do
  
  describe "mail receiver run" do
    describe "smtp method" do
      after do
        Mail::TestMailer.deliveries.clear
      end
      before do
        @properties = YAML.load_file(File.join(__dir__, 'fixtures', 'properties_smtp.yml'))
      end
      describe "to whitelist" do
        before do
          ARGV.replace [File.join(__dir__, 'fixtures', 'email.txt')]
          MailForwarder.run(@properties)
        end
      
        it "delivers mail" do
          assert_equal(Mail::TestMailer.deliveries.length, 1)
        end
    
        it "changes recipient " do
          assert_equal(Mail::TestMailer.deliveries.first.to, [@properties['recipient']])
        end

        it "uses allowed sender " do
          assert_equal(Mail::TestMailer.deliveries.first.from, [@properties['allowed_sender']])
        end

        it "sets reply to to original sender " do
          assert_equal(Mail::TestMailer.deliveries.first.reply_to, ['ken@foo.bar'])
        end

        it "uses allowed sender " do
          assert_equal(Mail::TestMailer.deliveries.first.from, [@properties['allowed_sender']])
        end

        it "sets reply to to original sender " do
          assert_equal(Mail::TestMailer.deliveries.first.reply_to, ['ken@foo.bar'])
        end
    
      end

      describe "not to whitelist" do
        before do
          ARGV.replace [File.join(__dir__, 'fixtures', 'email_bad_recipient.txt')]
          MailForwarder.run(@properties)
        end

        it "doesn't deliver mail" do
          assert_equal(Mail::TestMailer.deliveries.length, 0)
        end
      end

      describe "from blacklist" do
        before do
          ARGV.replace [File.join(__dir__, 'fixtures', 'email_bad_sender.txt')]
          MailForwarder.run(@properties)
        end

        it "doesn't deliver mail" do
          assert_equal(Mail::TestMailer.deliveries.length, 0)
        end
      end
    
      describe "no file in ARGV" do
        before do
          MailForwarder.run(@properties)
        end

        it "doesn't deliver mail" do
          assert_equal(Mail::TestMailer.deliveries.length, 0)
        end
      end
    end
  end
end