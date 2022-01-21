module Game
  module Resources
    class Participations < Grape::API
      resource :rooms do
        route_param :id, type: Integer do
          resource :participation do
            finally do
              # header 'Authorization', refresh_token if headers['Authorization'].present?
            end
            desc 'Join the room'
            post do
              authenticate!

              room.users << current_user
              room.save!

              present room, with: Game::Entities::Room
            end

            desc 'Leave the room'
            delete do
              authenticate!

              if room.owner == current_user
                room.destroy!
              else
                room.users.delete(current_user.id)
              end

              status 204
            end
          end
        end
      end
    end
  end
end
