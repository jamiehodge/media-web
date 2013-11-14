require_relative "upload"

module Media
  module Web
    module Parameters
      class Base
        UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

        attr_reader :params, :pattern

        def initialize(params, options = {})
          @params  = params
          @pattern = options.fetch(:pattern, UUID)
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

        def upload(name = "file")
          Upload.new(params[name])
        end
      end
    end
  end
end
