module Game
  module Helpers
    module ApiHelper
      def room
        @room ||= Room.find(params[:id])
      end

      def current_user
        if token.blank?
          @current_user = nil
        else
          @current_user = User.find(token.first['id'])
        end
      end

      def refresh_token
        payload = JWT.decode(headers['Authorization'], ENV['JWT_SECRET']).first
        payload[:exp] = 24.hours.from_now.to_i
        JWT.encode(payload, ENV['SECRET_KEY'])
      end

      def authenticate!
        if token.blank?
          raise Shared::Exceptions::InvalidJwt
        else
          current_user
        end
      end

      def token
        if headers['Authorization'].blank?
          nil
        else
          JWT.decode(headers['Authorization'], ENV['JWT_SECRET'])
        end
      end

      def can?(action, model_or_instance)
        Ability.new(current_user).authorize!(action, model_or_instance)
      end
    end
  end
end
