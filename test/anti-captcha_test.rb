require 'minitest/autorun'
require 'webmock/minitest'
require 'anti-captcha'

HTTPI.log = false

class TestAntiCaptchaConfigure < MiniTest::Unit::TestCase
  def setup
    AntiCaptcha.configure do |config|
      config.key = 'test_key'
      config.phrase = 1
    end
  end

  def test_configuration_default_options
    assert_equal({ key: "test_key", phrase: 1, regsense: 0, numeric: 0, calc: 0,
                 min_len: 0, max_len: 0, is_russian: 0 },
                 AntiCaptcha.configuration.options)
  end
end

class TestAntiCaptcha < MiniTest::Unit::TestCase
  def setup
    AntiCaptcha.configure do |config|
      config.key = 'test_key'
    end
    @client = AntiCaptcha::Client.new(sleep: 0, retries_count: 1)
  end

  def test_success_request
    stub_request(:post, "http://anti-captcha.com/in.php").
      to_return(status: 200, body: 'OK|request_id')

    stub_request(:post, "http://anti-captcha.com/res.php").
      with(body: {"action"=>"get", "id"=>"request_id", "key"=>"test_key"}).
      to_return(status: 200, body: 'CAPCHA_NOT_READY').then.
      to_return(status: 200, body: 'OK|result')

    result = @client.decode 'file_content'
    assert_equal 'result', result
  end

  def test_with_retries
    stub_request(:post, "http://anti-captcha.com/in.php").
      to_return(status: 200, body: 'OK|request_id')

    stub_request(:post, "http://anti-captcha.com/res.php").
      with(body: {"action"=>"get", "id"=>"request_id", "key"=>"test_key"}).
      to_return(status: 200, body: 'CAPCHA_NOT_READY').then.
      to_return(status: 200, body: 'CAPCHA_NOT_READY')

    assert_raises AntiCaptcha::CaptchaNotReady do
      @client.decode 'file_content'
    end
  end

  %w(ERROR_KEY_DOES_NOT_EXIST ERROR_WRONG_ID_FORMAT ERROR_CAPTCHA_UNSOLVABLE).each do |error_message|
    define_method "test_status_#{error_message}" do
      stub_request(:post, "http://anti-captcha.com/in.php").
        to_return(status: 200, body: 'OK|request_id')

      stub_request(:post, "http://anti-captcha.com/res.php").
        with(body: {"action"=>"get", "id"=>"request_id", "key"=>"test_key"}).
        to_return(status: 200, body: error_message)

      assert_raises "AntiCaptcha::#{error_message.gsub(/^ERROR_/,'').downcase.classify}".constantize do
        @client.decode 'file_content'
      end
    end
  end

  %w(ERROR_WRONG_USER_KEY ERROR_KEY_DOES_NOT_EXIST ERROR_ZERO_BALANCE
     ERROR_NO_SLOT_AVAILABLE ERROR_ZERO_CAPTCHA_FILESIZE
     ERROR_TOO_BIG_CAPTCHA_FILESIZE ERROR_WRONG_FILE_EXTENSION
     ERROR_IMAGE_TYPE_NOT_SUPPORTED ERROR_IP_NOT_ALLOWED).each do |error_message|

    define_method("test_request_#{error_message}") do
      stub_request(:post, "http://anti-captcha.com/in.php").
        to_return(status: 200, body: error_message)

      assert_raises "AntiCaptcha::#{error_message.gsub(/^ERROR_/,'').downcase.classify}".constantize do
        @client.decode 'file_content'
      end
    end
  end

  def test_unknown_response
    stub_request(:post, "http://anti-captcha.com/in.php").
      to_return(status: 200, body: 'unknown')

    assert_raises AntiCaptcha::UnknownResponse do
      @client.decode 'file_content'
    end
  end

  def test_unknown_error_response
    stub_request(:post, "http://anti-captcha.com/in.php").
      to_return(status: 200, body: 'ERROR_unknown')

    assert_raises AntiCaptcha::UnknownErrorResponse do
      @client.decode 'file_content'
    end
  end

  def test_report_bad
    @client.instance_variable_set :@captcha_id, 'test_id'
    stub_request(:post, "http://anti-captcha.com/res.php").
      with(body: {"action"=>"reportbad", "id"=>"test_id", "key"=>"test_key"}).
      to_return(status: 200, body: 'ok')

    assert @client.report_bad
  end

  def test_get_balance
    stub_request(:post, "http://anti-captcha.com/res.php").
      with(body: {"action"=>"getbalance", "key"=>"test_key"}).
      to_return(status: 200, body: '10.05')

    assert_equal '10.05', @client.get_balance
  end

  def test_get_stats
    stub_request(:post, "http://anti-captcha.com/res.php").
      with(body: {"action" => "getstats", "key"=>"test_key", "date" => Date.today.strftime('%Y-%m-%d')}).
      to_return(status: 200, body: '<?xml version="1.0"?><response></response>')

    assert_equal '<?xml version="1.0"?><response></response>', @client.get_stats
  end

end
