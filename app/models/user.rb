# An application user.
class User < ApplicationRecord
  has_secure_password
  has_many :terms

  with_options presence: true do |o|
    o.validates :username, uniqueness: { case_sensitive: false }
    o.validates :password, confirmation: true
    o.validates :password_confirmation
  end

  def token
    if id
      @token ||= JsonWebToken.encode({ user_id: id })
    else
      raise 'JSON web token missing database id'
    end
  end

  # Serializes an user.
  def serialize
    { id:         id,
      username:   username,
      auth_token: token }
  end
end
