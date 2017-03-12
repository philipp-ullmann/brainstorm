# An application user.
class User < ApplicationRecord
  has_secure_password
  has_many :terms

  with_options presence: true do |o|
    o.validates :username, uniqueness: { case_sensitive: false }
    o.validates :password, confirmation: true
    o.validates :password_confirmation
  end

  # Serializes an user.
  def serialize
    { id:         id,
      username:   username,
      auth_token: JsonWebToken.encode({ user_id: id }) }
  end
end
