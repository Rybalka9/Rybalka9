module Game 
  module Resources
    class Articles < Grape::API
      helpers do
        def article
          @article ||= Article.find(params[:id])
        end
      end

      resource :articles do
        desc 'Display all articles'
        get do
          articles = Article.all

          present articles, with: Game::Entities::Article
        end

        desc 'Create a new article'
        params do
          requires :title, type: String
          requires :body, type: String
        end
        post do
          created_article = Article.create!(params)
          present created_article, with: Game::Entities::Article
        end
        
        route_param :id, type: Integer do
          desc 'Show an article'
          get do
            present article, with: Game::Entities::Article
          end

          desc 'Update an article'
          params do
            optional :title, type: String
            optional :body, type: String
          end
          patch do
            article.update!(params)
            present article, with: Game::Entities::Article
          end

          desc 'Delete an article'
          delete do
            article.destroy!
            status 204
          end
        end
      end
    end
  end
end
