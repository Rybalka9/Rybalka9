require 'rails_helper'

describe Game::Resources::Authentications do
  let(:base_url) { '/authentications' }
  let!(:user) { create :user }
  let!(:token) { JWT.encode({ id: user.id, email: user.email, exp: (Time.now + 1.day).to_i }, ENV['JWT_SECRET']) }
  let!(:header) { { 'Authorization' => token } }

  describe "GET /authentications" do
    context 'Without JWT' do
      it 'should return null' do
        get base_url

        expect_status 200
        expect_json(nil)
      end
    end
    context 'With JWT' do
      it "should return user`s id" do
        get base_url, headers: header

        expect_status 200
        expect(JWT.decode(token, ENV["JWT_SECRET"]).first['id'] == user.id)
      end
    end
  end

  describe "POST /authentications" do
    let!(:params) { {email: user.email, password: user.password} }
    let!(:test_token) { {id: user.id, email: user.email, exp: (Time.now + 1.day).to_i}}
    let!(:expected_token) {JWT.encode(test_token, ENV["JWT_SECRET"])}
    context 'With valid params' do
      it 'should return JWT' do
        post base_url, params: params

        expect_status 201
        expect(json).to eq expected_token
      end
    end

    context 'With invalid params' do
      it 'should return status 404' do
        post base_url, params: { email: 'qwe', password: '...'}

        expect_status 404
        expect_json_keys(:message)
        expect_json_types(message: :string)
        expect_json(message: 'RECORD_NOT_FOUND')
      end
    end

    context 'With valid email but with invalid password' do
      it 'should return status 404' do
        post base_url, params: { email: 'text@gmail.com', password: '...'}

        expect_status 404
        expect_json_keys(:message)
        expect_json_types(message: :string)
        expect_json(message: 'INVALID_PASSWORD')
      end
    end
  end
end