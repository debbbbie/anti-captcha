require 'anti-captcha/version'
require 'anti-captcha/configuration'
require 'anti-captcha/client'
require 'anti-captcha/error'

module AntiCaptcha

  def self.configure(&block)
    yield(configuration)
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

end
