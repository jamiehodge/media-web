module Media
  module Web
    module Policies
      class Base
        attr_reader :person, :item

        def initialize(person, item)
          @person = person
          @item   = item
        end

        def self.collection(person, dataset)
          dataset.nullify
        end

        def collection
          self.class.collection(person, item.class.dataset)
        end

        def index?
          false
        end

        def show?
          collection.where(id: item.id).exists
        end

        def create?
          false
        end

        def new?
          create?
        end

        def update?
          false
        end

        def edit?
          updated?
        end

        def destroy?
          false
        end

        def fields
          []
        end
      end
    end
  end
end