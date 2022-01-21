class User < ApplicationRecord
  has_secure_password :validations => false
  has_one :users_room
  has_one :room, through: :users_room

  validates :email, presence: true, uniqueness: true, format:
            { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/,
              message: "Please enter the correct Email" }
  validates :password, presence: true, format:
    { with:  /(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{8,}/,
      message: "Password must contain at least one lowercase letter, one uppercase letter, one digit and must be at least 8 characters long" }
end
