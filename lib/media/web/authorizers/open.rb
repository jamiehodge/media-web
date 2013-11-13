require_relative "base"

module Media
  module Web
    module Authorizers
      class Open < Base

        def self.collection(person, dataset)
          dataset
        end

        def index?
          true
        end

        def show?
          collection.where(id: item.id).exists
        end

        def create?
          true
        end

        def update?
          true
        end

        def destroy?
          true
        end
      end
    end
  end
end
