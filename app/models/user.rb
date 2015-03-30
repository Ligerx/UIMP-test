class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable


  scope :find_by_email, ->(input_email) { find_by(email: input_email) }


  def self.valid_login?(user_id, password)
    return false if user_id.nil? || password.nil?

    resource = User.find_by_email(user_id)
    return false if resource.nil?

    resource.valid_password?(password)
  end

end
