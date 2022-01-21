module Game
  module Entities
    class Room < Grape::Entity
      expose :id, :name, :created_at, :updated_at
      expose :owner, using: Game::Entities::User
      expose :users, using: Game::Entities::User
    end
  end
end
