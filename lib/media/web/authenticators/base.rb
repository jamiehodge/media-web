module Media
  module Web
    module Authenticators
      class Base

        attr_reader :context, :authenticator

        def initialize(context, authenticator)
          @context = context
          @authenticator = authenticator
        end

        def authentication
          authenticator[id] if authenticator
        end

        def id
          context.request_headers.remote_user
        end

        def person_id
          authentication.person_id if authentication
        end
      end
    end
  end
end
