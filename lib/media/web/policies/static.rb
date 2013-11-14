require_relative "base"

module Media
  module Web
    module Policies
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
