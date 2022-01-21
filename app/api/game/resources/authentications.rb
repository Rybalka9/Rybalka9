module Game
  module Resources
    class Authentications < Grape::API
      helpers do
        def token(user_id, email)
          payload = { id: user_id, email: email, exp: (Time.now + 1.day).to_i}
          JWT.encode(payload, hmac_secret, 'HS256')
        end

        def hmac_secret
          ENV["JWT_SECRET"]
        end

        def client_has_valid_token?
          !!current_user_id
        end

        def current_user_id
          begin
            token = headers["Authorization"]
            decoded_array = JWT.decode(token, hmac_secret, true, { algorithm: 'HS256' })
            payload = decoded_array.first
          rescue #JWT::VerificationError
            return nil
          end
          payload["id"]
        end
      end

      resource :authentications do
        desc 'Create a new auth'
        params do
          requires :email, type: String
          requires :password, type: String
        end
        post do
          user = User.find_by!(email: params[:email])
          if user.authenticate(params[:password])
            token(user.id, user.email)
          else
            error!({message: 'INVALID_PASSWORD'}, 404)
          end
        end

        desc 'Get an auth'
        get do
          current_user_id
        end
      end
    end
  end
end
