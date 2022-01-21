require 'rails_helper'

describe Game::Resources::Rooms do
  let(:base_url) { "/rooms/#{room.id}/participation" }
  let!(:user) { create :user }

  let!(:token) { JWT.encode({ id: user.id, email: user.email, exp: (Time.now + 1.day).to_i }, ENV['JWT_SECRET']) }
  let!(:header) { { 'Authorization' => token } }
  let(:room_keys) { %i[name owner users created_at updated_at id] }
  let(:room_types) { Hash[name: :string, owner: :object, users: :array, id: :integer, created_at: :string, updated_at: :string] }
  let(:user_keys) { %i[id email password_digest created_at updated_at admin] }
  let(:user_types) { Hash[id: :integer, email: :string, password_digest: :string, created_at: :string, updated_at: :string, admin: :boolean] }

end