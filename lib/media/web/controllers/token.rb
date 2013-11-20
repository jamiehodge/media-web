module Media
  module Web
    module Controllers
      class Token

        attr_reader :key, :value

        def initialize(request)
          @key, @value = request["Authorization"].to_s.split(" ", 2)
        end
      end
    end
  end
end
