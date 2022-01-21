require 'rails_helper'

describe Game::Resources::Rooms do
  let(:base_url) { '/rooms' }
  let!(:user) { create :user }

  let!(:token) { JWT.encode({ id: user.id, email: user.email, exp: (Time.now + 1.day).to_i }, ENV['JWT_SECRET']) }
  let!(:header) { { 'Authorization' => token } }
  let(:room_keys) { %i[name owner users created_at updated_at id] }
  let(:room_types) { Hash[name: :string, owner: :object, users: :array, id: :integer, created_at: :string, updated_at: :string] }
  let(:user_keys) { %i[id email password_digest created_at updated_at admin] }
  let(:user_types) { Hash[id: :integer, email: :string, password_digest: :string, created_at: :string, updated_at: :string, admin: :boolean] }

  describe "GET /rooms" do
    context 'Without JWT' do
      it 'should return 401' do
        get base_url

        expect_status 401
        expect_json_keys(:message)
        expect_json_types(message: :string)
        expect_json(message: 'THERE_IS_NO_JWT')
      end
    end
    context 'With JWT' do
      let!(:room) { create(:room, owner: user, users: [user]) }
      it "should return room list" do
        get base_url, headers: header

        expect_status 200
        expect_json_sizes(1)
        expect_json_keys('*', room_keys)
        expect_json_types('*', room_types)
        expect_json_types('*.users.*', user_types)
        expect_json_keys('*.users.*', user_keys)
        expect_json_types('*.owner', user_types)
        expect_json_keys('*.owner', user_keys)
      end
    end
  end

  describe "GET /rooms/:id" do
    let!(:room) { create(:room, owner: user) }
    context 'Without JWT' do
      it 'should return 401' do
        get "#{base_url}/#{room.id}"

        expect_status 401
        expect_json(message: 'THERE_IS_NO_JWT')
      end
    end

    context 'With JWT' do
      let!(:room) { create(:room, owner: user, users: [user]) }
      it "should return room list" do
        get "#{base_url}/#{room.id}", headers: header

        expect_status 200
        expect_json_keys(room_keys)
        expect_json_types(room_types)
        expect_json_sizes(room_keys.size)
        expect_json_types('users.*', user_types)
        expect_json_keys('users.*', user_keys)
        expect_json_types('owner', user_types)
        expect_json_keys('owner', user_keys)
      end
    end

    context 'With JWT but non existing :id' do
      it "should return created room's json" do
        get "#{base_url}/0", headers: header

        expect_status 404
        expect_json_keys(:message)
        expect_json_types(message: :string)
        expect_json(message: 'RECORD_NOT_FOUND')
      end
    end
  end

  describe "POST /rooms" do
    let!(:params) { {name: 'RoomName', owner_id: user.id} }
    let(:room) { create(:room, name: params[:name], owner_id: params[:owner_id]) }

    context 'With JWT' do
      it 'should return created room' do
        expect { post base_url, headers: header, params: params }.to change { Room.count }.by 1

        expect_status 201
        expect_json_keys(room_keys)
        expect_json_types(room_types)
        expect_json_sizes(room_keys.size)
        expect_json_types('users.*', user_types)
        expect_json_keys('users.*', user_keys)
        expect_json_types('owner', user_types)
        expect_json_keys('owner', user_keys)
      end
    end

    context 'With JWT but owner and room name have already been taken' do
      it 'should return 422' do
        Room.create(params)
        expect { post base_url, headers: header, params: params }.to change { Room.count }.by 0

        expect_status 422
        expect_json_keys(%i[message error])
        expect_json_types(message: :string, error: :string)
        expect_json(message: 'RECORD_INVALID',
                    error: 'Validation failed: Name has already been taken, Owner has already been taken')
      end
    end

    context 'With JWT but owner has already been taken' do
      it 'should return 422' do
        Room.create({name: 'RoomName1', owner_id: user.id})
        expect { post base_url, headers: header, params: params }.to change { Room.count }.by 0

        expect_status 422
        expect_json_keys(%i[message error])
        expect_json_types(message: :string, error: :string)
        expect_json(message: 'RECORD_INVALID',
                    error: 'Validation failed: Owner has already been taken')
      end
    end

    context 'With JWT but name has already been taken' do
      let(:owner_user) { create :user }
      it 'should return 422' do
        Room.create({name: 'RoomName', owner_id: owner_user.id})
        expect { post base_url, headers: header, params: params }.to change { Room.count }.by 0

        expect_status 422
        expect_json_keys(%i[message error])
        expect_json_types(message: :string, error: :string)
        expect_json(message: 'RECORD_INVALID',
                    error: 'Validation failed: Name has already been taken')
      end
    end

    context 'With JWT but user is already in other room' do
      let(:owner_user) { create :user }
      it 'should return 422' do
        first_room = Room.create({name: 'RoomName228', owner_id: owner_user.id})
        first_room.users << user
        first_room.save!
        expect { post base_url, headers: header, params: params }.to change { Room.count }.by 0

        expect_status 422
        expect_json_keys([:message])
        expect_json_types(message: :string)
        expect_json(message: 'User is already in other room')
      end
    end

    context 'Without JWT' do
      it 'should return 401' do
        expect { post base_url, params: params }.to change { Room.count }.by 0

        expect_status 401
        expect_json_keys(:message)
        expect_json_types(message: :string)
        expect_json(message: 'THERE_IS_NO_JWT')
      end
    end
  end

  describe "DELETE /rooms/:id" do
    let!(:room) { create(:room, owner: user) }
    context 'Without JWT' do
      it 'should return 401' do
        expect { delete "#{base_url}/#{room.id}" }.to change { Room.count }.by 0

        expect_status 401
        expect_json_keys(:message)
        expect_json_types(message: :string)
        expect_json(message: 'THERE_IS_NO_JWT')
      end
    end

    context 'With JWT but the user is not an owner' do
      let(:test_user) { create :user }
      let(:test_header) { { 'Authorization' => test_token } }
      let(:test_token) { JWT.encode({ id: test_user.id, email: test_user.email, exp: (Time.now + 1.day).to_i }, ENV['JWT_SECRET']) }
      it 'should return 403' do
        expect { delete "#{base_url}/#{room.id}", headers: test_header }.to change { Room.count }.by 0

        expect_status 403
        expect_json_keys(%i[message error])
        expect_json_types(message: :string, error: :string)
        expect_json(message: 'ACCESS_DENIED',
                    error: 'You are not authorized to access this page.')
      end
    end
  end
end