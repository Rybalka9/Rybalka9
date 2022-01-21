require 'rails_helper'

describe Game::Resources::Users do
  let(:base_url) { '/users' }
  let!(:user) { create :user }
  let(:user_keys) { %i[email password_digest admin] }
  let(:user_types) { Hash[email: :string, password_digest: :string, admin: :boolean] }
  let!(:token) { JWT.encode({ id: user.id, email: user.email, exp: (Time.now + 1.day).to_i }, ENV['JWT_SECRET']) }
  let!(:header) { { 'Authorization' => token } }

  describe 'GET /users' do
    it 'When shows all users' do
      get base_url

      expect_status 200
      expect_json_sizes 1
      expect_json_keys('*', user_keys)
      expect_json_types('*', user_types)
    end
  end

  describe 'POST /users' do
    let(:params) { Hash[email: 'testing@mail.com', password: 'Pass1234'] }

    context 'Data is valid' do
      it 'When create a new user with valid params' do

        expect { post base_url, params: params }.to change { User.count }.by 1

        expect_status(201)
        expect_json_keys(user_keys)
        expect_json_types(user_types)
        expect_json(email: 'testing@mail.com')
      end
    end

    context 'Data is invalid' do
      it 'When create a new user with valid email and invalid password' do
        post base_url, params: { email: 'testing@mail.com', password: 'pass12345' }

        expect_status(422)
        expect_json_keys(:message)
        expect_json_types(message: :string)
      end

      it 'When create a new user with invalid email and valid password' do
        post base_url, params: { email: 'testing@mailcom', password: 'Pass1234' }

        expect_status(422)
        expect_json_keys(:message)
        expect_json_types(message: :string)
      end

      it 'When create a new user with invalid email and invalid password' do
        post base_url, params: { email: 'testingmailcom', password: 'pass1234' }

        expect_status(422)
        expect_json_keys(:message)
        expect_json_types(message: :string)
        expect_json(message: 'RECORD_INVALID')
      end
    end
  end

  describe 'DELETE /users/:id' do
    let!(:admin) { User.create!(email: 'email@gmail.com', password: '123Aa123', admin: true) }
    let!(:user) { User.create!(email: 'qweqwe@gmail.com', password: '123Aa123') }
    let!(:admin_token) { JWT.encode({ id: admin.id, email: admin.email, exp: (Time.now + 1.day).to_i }, ENV['JWT_SECRET']) }
    let!(:user_token) { JWT.encode({ id: user.id, email: user.email, exp: (Time.now + 1.day).to_i }, ENV['JWT_SECRET']) }
    let!(:admin_header) { { 'Authorization' => admin_token } }

    context 'Valid data :id' do
      it 'Deletes a user' do
        expect { delete "#{base_url}/#{admin.id}", headers: admin_header }.to change { User.count }.by -1
        expect_status 204
      end
    end

    context 'Invalid data :id' do
      it 'when trying delete without a token' do
        expect { delete "#{base_url}/#{admin.id}" }.to change { User.count }.by 0
        expect_status 401
        expect_json_keys(:message)
        expect_json_types(message: :string)
      end

      it 'when trying delete when user is not an admin' do
        expect { delete "#{base_url}/#{user.id}", headers: { 'Authorization' => user_token }}.to change { User.count }.by 0
        expect_status 403
        expect_json_keys(:message)
        expect_json_types(message: :string)
      end

      it 'when trying delete when headers are incorrect' do
        expect { delete "#{base_url}/#{admin.id}", headers: { 'Authorization' => user_token }
        }.to change { User.count }.by 0
        expect_status 403
      end
    end
  end

  describe 'GET /users/:id' do
    context 'With existing user :id' do
      it 'returns a user' do
        get "#{base_url}/#{user.id}"

        expect_status 200
        expect_json_keys(user_keys)
        expect_json_types(user_types)
      end
    end

    context 'With non-existing user :id' do
      it 'returns 404' do
        get "#{base_url}/0" do

          expect_status 404
          expect_json_keys(:message)
          expect_json_types(message: :string)
        end
      end
    end
  end

  describe 'PATCH /users/:id' do
    let(:params) { Hash[email: 'testing@mail.com', password: 'Zz123456'] }
    let!(:user_token) { JWT.encode({ id: user.id, email: user.email }, ENV['JWT_SECRET']) }

    context 'Data is valid :id' do
      it 'When update a user with valid params :id' do
        patch "#{base_url}/#{user.id}", headers: { 'Authorization' => user_token }, params: params

        expect_status 200
        expect_json_keys(user_keys)
        expect_json_types(user_types)
        expect_json(email: 'testing@mail.com')
      end
    end

    context 'Data is invalid :id' do
      it 'When update a user with invalid params :id' do
        patch "#{base_url}/#{user.id}", headers: { 'Authorization' => user_token },
              params: { email: 'testingmail.com', password: 'pass1234' }

        expect_status 422
        expect_json_keys(:message)
        expect_json_types(message: :string)
      end

      it 'When update a user with valid params but without token :id' do
        patch "#{base_url}/#{user.id}", params: params

        expect_status 401
        expect_json_keys(:message)
        expect_json_types(message: :string)
      end
    end
    context 'token expired' do
      let(:invalid_token) { JWT.encode({ id: user.id, email: user.email,
                                         exp: (Time.now - 1.day).to_i }, ENV['JWT_SECRET']) }
      it 'returns token expired error' do
        patch "#{base_url}/#{user.id}", params: params, headers: { 'Authorization' => invalid_token }

        expect_status(408)
      end
    end
  end
end
