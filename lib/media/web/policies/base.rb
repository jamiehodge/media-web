module Media
  module Web
    module Policies
      class Base
        attr_reader :person, :item

        def initialize(person, item)
          @person = person
          @item   = item
        end

        def collection
          Scope.new(person, item.class.dataset).resolve
        end

        def index?
          false
        end

        def show?
          collection.where(id: item.id).exists
        end

        def download?
          show?
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

        class Scope

          attr_reader :dataset, :person

          def initialize(person, dataset)
            @dataset = dataset
            @person  = person
          end

          def resolve
            dataset
          end
        end
      end
    end
  end
end
