require_relative "base"

module Media
  module Web
    module Authorizers
      class Static < Base

        def self.collection(person, dataset)
          dataset
        end

        def index?
          true
        end

        def show?
          true
        end
      end
    end
  end
end
