module Game
  module Resources
    class Users < Grape::API
      helpers do
        def user
          @user ||= User.find(params[:id])
        end
      end

      resource :users do
        finally do
          header 'Authorization', refresh_token if headers['Authorization'].present?
        end
        desc 'Display all users'
        get do
          can? :read, User
          users = User.all

          present users, with: Game::Entities::User
        end

        desc 'Create a new user'
        params do
          requires :email, type: String
          requires :password, type: String
        end
        post do
          can? :create, User
          created_user = User.create!(params)
          present created_user, with: Game::Entities::User
        end

        route_param :id, type: Integer do
          desc 'Show a user'
          get do
            present user, with: Game::Entities::User
          end

          desc 'Update a user'
          params do
            optional :email, type: String
            optional :password, type: String
          end
          patch do
            authenticate!
            can? :update, user
            user.update!(params)
            present user, with: Game::Entities::User
          end

          desc 'Delete a user'
          delete do
            authenticate!
            can? :delete, user
            user.destroy!
            status 204
          end
        end
      end
    end
  end
end
