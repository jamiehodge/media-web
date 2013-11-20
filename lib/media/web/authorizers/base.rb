module Media
  module Web
    module Authorizers
      class Base
        attr_reader :person, :item, :scoper

        def initialize(person, item, options = {})
          @person = person
          @item   = item
          @scoper = options.fetch(:scoper) { Scope }
        end

        def collection
          scoper.call(person, item.class)
        end

        def index?
          false
        end

        def show?
          !!collection[item.id]
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

        module Scope
          extend self

          def call(person, dataset)
            dataset
          end
        end
      end
    end
  end
end
