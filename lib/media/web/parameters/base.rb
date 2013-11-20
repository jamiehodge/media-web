require_relative "upload"

module Media
  module Web
    module Parameters
      class Base
        attr_reader :params, :pattern

        def initialize(params, options = {})
          @params  = params
          @pattern = options.fetch(:pattern)
        end

        def id
          params[:id].to_s[pattern, 0]
        end

        def limit
          [params[:limit].to_i, 10].max
        end

        def offset
          [params[:offset].to_i, 0].max
        end

        def password
          params[:password]
        end

        def person_id
          params[:person_id]
        end

        def query
          params[:query]
        end

        def token
          params[:token]
        end

        def upload(name = "file")
          Upload.new(params[name])
        end
      end
    end
  end
end
