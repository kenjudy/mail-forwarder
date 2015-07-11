require 'rubygems'
require 'bundler/setup'
require 'mail'
require 'yaml'
require 'sendgrid-ruby'

class MailForwarder

  def self.run(properties = YAML.load_file(File.join(__dir__, '..', 'config', 'properties.yml')))
    @properties = properties
    return unless ARGF.any?
    if @properties['method'] == 'smtp'
      deliver_smtp
    else
      deliver_sendgrid_webapi
    end
  end

  def self.send?(m)
    (@properties['whitelist_to'] & m.to).any? && (@properties['blacklist_from'] & m.from).blank?
  end

  def self.deliver_sendgrid_webapi
    client = SendGrid::Client.new(api_user: @properties['sendgrid_web_api']['username'], api_key: @properties['sendgrid_web_api']['password'])
    source = Mail.new ARGF.read
    if send?(source)
      mail = SendGrid::Mail.new do |m|
        m.to = @properties['recipient']
        reply_to = source.from
        m.from =  @properties['allowed_sender']
        m.reply_to = reply_to.first
        m.subject = "#{reply_to.first}: #{source.subject}"
        m.text = source.text_part
        m.html = source.html_part
      end
      client.send(mail)
    end
  end

  def self.deliver_smtp
    prepare_smtp_mail
    m = Mail.new ARGF.read
    if send?(m)
      reply_to = m.from
      m.to = @properties['recipient']
      m.reply_to = reply_to.first
      m.from = @properties['allowed_sender']
      result = Mail.deliver m
    end
    return result
  end

  def self.prepare_smtp_mail
    unless ENV['environment'] == 'test'
      Mail.defaults do
        delivery_method :smtp, { address: @properties['smtp']['address'],
                                 port: @properties['smtp']['port'],
                                 domain: @properties['smtp']['domain'],
                                 user_name: @properties['smtp']['user_name'],
                                 password: @properties['smtp']['password'],
                                 authentication: @properties['smtp']['authentication'],
                                 enable_starttls_auto: @properties['smtp']['enable_starttls_auto'] }
      end
    else
      Mail.defaults do
        delivery_method :test
      end
    end
  end
end