module AntiCaptcha

  class Error < StandardError
  end

  class UnknownResponse < Error
  end

  class UnknownErrorResponse < Error
  end

  class WrongUserKey < Error
  end

  class KeyDoesNotExist < Error
  end

  class ZeroBalance < Error
  end

  class NoSlotAvailable < Error
  end

  class ZeroCaptchaFilesize < Error
  end

  class TooBigCaptchaFilesize < Error
  end

  class WrongFileExtension < Error
  end

  class ImageTypeNotSupported < Error
  end

  class IpNotAllowed < Error
  end

  class CaptchaNotReady < Error
  end

  class WrongIdFormat < Error
  end

  class CaptchaUnsolvable < Error
  end

end
