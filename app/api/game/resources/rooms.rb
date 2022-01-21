module Game
  module Resources
    class Rooms < Grape::API
      resource :rooms do
        finally do
          # header 'Authorization', refresh_token if headers['Authorization'].present?
        end
        desc 'Display all rooms'
        get do
          authenticate!
          can? :read, Room
          rooms = Room.includes(:users)

          present rooms, with: Game::Entities::Room
        end

        desc 'Create a new room'
        params do
          requires :name, type: String
        end
        post do
          authenticate!
          can? :create, Room
          if UsersRoom.exists?(user_id: current_user.id)
            error!({message: 'User is already in other room'}, 422)
          else
            created_room = Room.create!(name: params[:name], owner: current_user)
            created_room.users << current_user
            created_room.save!
            present created_room, with: Game::Entities::Room
          end
        end

        route_param :id, type: Integer do
          desc 'Display a specific room'
          get do
            authenticate!
            can? :read, room

            present room, with: Game::Entities::Room
          end

          desc 'Delete a room'
          delete do
            authenticate!
            can? :destroy, room
            room.destroy!
            status 204
          end
        end
      end
    end
  end
end
