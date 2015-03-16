class Token < ActiveRecord::Base
  require 'DateTime'

  # how long a token remains valid in seconds
  VALID_TIME = 36000

  scope :valid, -> { where("expiration_date > ?", DateTime.current) }

  before_create :generate_access_token, :set_expiration_date


  def time_till_expiration
    # subtracting two DateTimes returns a Date
    ((self.expiration_date - DateTime.current) * 24 * 60 * 60).to_i
  end
  

  private
  # do I need to check that this token is unique?
  def generate_access_token
    allowed_chars = [*'0'..'9', *'a'..'z', *'A'..'Z'].join
    self.access_token = 128.times.map { allowed_chars[allowed_chars.size] }.join
  end

  def set_expiration_date
    self.expiration_date = VALID_TIME.seconds.from_now
  end
end
