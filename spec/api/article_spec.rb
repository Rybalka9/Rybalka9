require 'rails_helper'

describe Game::Resources::Articles do
  let!(:article) { create :article }
  let(:base_url) { '/articles' }
  let(:article_keys) { %i[id body title updated_at created_at] }
  let(:article_types) { Hash[body: :string, title: :string] }

  describe 'GET /articles' do
    it 'When shows all articles' do
      get base_url
      
      expect_status 200
      expect_json_sizes 1
      expect_json_keys('*', article_keys)
      expect_json_types('*', article_types)
    end
  end

  describe 'POST /articles' do
    let(:params){ Hash[title: 'Created', body: 'Created!!!!!!!'] }

    context 'Data is valid' do
      it 'When create a new article with valid params' do
        expect { post base_url, params: params }.to change { Article.count }.by 1
        
        expect_status(201)
        expect_json_keys(article_keys)
        expect_json_types(article_types)
        expect_json(title: 'Created', body: 'Created!!!!!!!')
      end
    end    

    context 'Data is invalid' do
      it 'When create a new article with invalid params' do
        post base_url, params: { title: 'q', body: 'w' }

        expect_status(422)
        expect_json_keys(:message)
        expect_json_types(message: :string)
      end
    end
  end

  describe 'GET /articles/:id' do
    context 'with existing article :id' do
      it 'returns article' do
        get "#{base_url}/#{article.id}"

        expect_status 200
        expect_json_keys(article_keys)
        expect_json_types(article_types)
      end
    end

    context 'with non-existing article :id' do
      it 'returns 404' do
        get "#{base_url}/0" do

          expect_status 404
          expect_json_keys(:message)
          expect_json_types(message: :string)
        end
      end
    end
  end

  describe 'PATCH /articles/:id' do
    let(:params) { Hash[title: 'Updated', body: 'Updated!!!'] }
    
    context 'Data is valid :id' do
      it 'When update an article with valid params' do
        patch "#{base_url}/#{article.id}", params: params
        
        expect_status 200
        expect_json_keys(article_keys)
        expect_json_types(article_types)
        expect_json(title: 'Updated', body: 'Updated!!!')
      end
    end

    context 'Data is invalid :id' do
      it 'When update an article with invalid params' do
        patch "#{base_url}/#{article.id}", params: { title: 'q', body: 'w' }
        
        expect_status 422
        expect_json_keys(:message)
        expect_json_types(message: :string)
      end
    end
  end

  describe 'DELETE /articles/:id' do
    context 'Resource exists :id' do
      it 'When delete an article' do
        expect { delete "#{base_url}/#{article.id}" }.to change { Article.count }.by -1
        expect_status 204
      end
    end
  end
end
