class Token < ActiveRecord::Base
  require 'date'

  # how long a token remains valid in seconds
  VALID_TIME = 36000

  belongs_to :user

  before_create :generate_access_token, :set_expiration_date

  scope :valid, -> { where("expiration_date > ?", DateTime.current) }

  def time_till_expiration
    # subtracting two DateTimes returns a Date
    # ((self.expiration_date - DateTime.current) * 24 * 60 * 60).to_i
    (self.expiration_date - DateTime.current).to_i
  end

  def expired?
    (time_till_expiration <= 0) ? true : false
  end

  def not_expired?
    !expired?
  end

  private
  # do I need to check that this token is unique?
  def generate_access_token
    allowed_chars = [*'0'..'9', *'a'..'z', *'A'..'Z'].join
    self.access_token = 128.times.map { allowed_chars[rand(allowed_chars.size)] }.join
  end

  def set_expiration_date
    self.expiration_date = VALID_TIME.seconds.from_now.to_datetime
  end
end
