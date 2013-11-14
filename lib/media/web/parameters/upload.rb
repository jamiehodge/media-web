module Media
  module Web
    module Parameters
      class Upload
        attr_reader :params

        def initialize(params)
          @params = params
        end

        def file
          params[:tempfile]
        end

        def name
          params[:filename]
        end

        def size
          file.size
        end

        def type
          params[:type]
        end

        def to_h
          return {} unless params

          {
            "file" => file,
            "name" => name,
            "size" => size,
            "type" => type
          }
        end
      end
    end
  end
end
