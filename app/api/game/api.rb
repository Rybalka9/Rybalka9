require 'grape-swagger'

module Game
  class Api < Grape::API
    format :json

    helpers Helpers::ApiHelper

    rescue_from ActiveRecord::RecordNotFound do |e|
      error!({message: 'RECORD_NOT_FOUND'}, 404)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      error!({message: 'RECORD_INVALID', error: e}, 422)
    end

    rescue_from Shared::Exceptions::InvalidJwt do |_e|
      error!({message: 'THERE_IS_NO_JWT'}, 401)
    end

    rescue_from ActiveModel::UnknownAttributeError do |e|
      error!({message: 'UNKNOWN_ATTRIBUTE'}, 406)
    end

    rescue_from CanCan::AccessDenied do |e|
      error!({message: 'ACCESS_DENIED', error: e}, 403)
    end

    rescue_from JWT::ExpiredSignature do
      error!({message: 'TOKEN_EXPIRED'}, 408)
    end

    mount Game::Resources::Articles
    mount Game::Resources::Users
    mount Game::Resources::Authentications
    mount Game::Resources::Rooms
    mount Game::Resources::Participations

    add_swagger_documentation
    route :any, '*path' do
      error!('Route not found', 404)
    end
  end
end
