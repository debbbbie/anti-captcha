require 'httpi'
require 'active_support/core_ext/string'
require 'active_support/core_ext/object'

module AntiCaptcha
  class Client

    def initialize(options = {})
      @retries_count = options.delete(:retries_count) || 10
      @sleep = options.delete(:sleep) || 5
      @options = AntiCaptcha.configuration.options.merge(options)
    end

    # type: file data (bin)
    # type: base64    (base64)
    def decode(image, type = :bin)
      case request_image(image, type)
      when /OK\|(.+)/
        @captcha_id = $1
        check
      when /^ERROR_(.+)/
        raise error_class($1)
      else
        raise UnknownResponse
      end
    end

    def check
      return if @captcha_id.blank?
      begin
        get_status
      rescue CaptchaNotReady => e
        attempt ||= @retries_count
        raise e if (attempt -= 1) < 0
        sleep @sleep
        retry
      end
    end

    def report_bad
      return if @captcha_id.blank?
      request_report_bad
    end

    def get_balance
      request_balance
    end

    def get_stats(date = Date.today)
      request_stats date
    end

    private

    def get_status
      case request_status
      when /^OK\|(.+)/
        $1
      when 'CAPCHA_NOT_READY'
        raise CaptchaNotReady
      when /^ERROR_(.+)/
        raise error_class($1)
      else
        raise UnknownResponse
      end
    end

    def request_status
      request 'http://anti-captcha.com/res.php',
        key: AntiCaptcha.configuration.key,
        action: 'get',
        id: @captcha_id
    end

    # type: file data (bin)
    # type: base64    (base64)
    def request_image(image, type = :bin)
      body = (type == :bin ? Base64.encode64(image) : image)
      request 'http://anti-captcha.com/in.php',
        @options.merge(method: 'base64', body: body)
    end

    def request_report_bad
      request 'http://anti-captcha.com/res.php',
        key: AntiCaptcha.configuration.key,
        action: 'reportbad',
        id: @captcha_id
    end

    def request_balance
      request 'http://anti-captcha.com/res.php',
        key: AntiCaptcha.configuration.key,
        action: 'getbalance'
    end

    def request_stats(date)
      request 'http://anti-captcha.com/res.php',
        key: AntiCaptcha.configuration.key,
        action: 'getstats',
        date: date.strftime('%Y-%m-%d')
    end

    def request(url, params)
      request = HTTPI::Request.new.tap do |request|
        request.url = url
        request.body = params
      end
      HTTPI.post(request).body
    end

    def error_class(string)
      "AntiCaptcha::#{string.downcase.classify}".constantize
    rescue NameError
      UnknownErrorResponse
    end

  end
end
