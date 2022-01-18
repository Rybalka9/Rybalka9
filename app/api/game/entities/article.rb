module Game
  module Entities
    class Article < Grape::Entity
      expose :id, :title, :body, :created_at, :updated_at
    end
  end
end
