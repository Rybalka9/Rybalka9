module Shared
  module Helpers
    def json
      JSON.parse(response.body)
    end
  end
end