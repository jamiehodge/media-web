module Media
  module Web
    module Authenticators
      class Base

        def initialize(context, authenticator)
          @context = context
          @authenticator = authenticator
        end

        def authentication
          authenticator[id]
        end

        def id
          context.request_headers.remote_user
        end

        def person_id
          authentication && authentication.person_id
        end
      end
    end
  end
end
