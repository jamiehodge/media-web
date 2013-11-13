module Media
  module Web
    module Headers
      class Base

        def initialize(headers)
          @headers = headers
        end

        def remote_user
          headers["REMOTE_USER"] || ENV["REMOTE_USER"]
        end
      end
    end
  end
end
