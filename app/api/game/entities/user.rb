module Game
  module Entities
    class User < Grape::Entity
      expose :id, :email, :password_digest, :created_at, :updated_at, :admin
    end
  end
end
