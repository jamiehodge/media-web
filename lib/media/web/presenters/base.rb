module Media
  module Web
    module Presenters
      class Base

        attr_reader :context, :item

        def self.create(context, obj)
          if obj.respond_to?(:each)
            Collection.new obj.map {|o| new(context, o) }
          else
            new(context, obj)
          end
        end

        def initialize(context, item)
          @context = context
          @item = item
        end

        def etag
          item.lock_version
        end

        def last_modified
          item.updated_at
        end

        private

        class Collection

          attr_reader :items

          def initialize(items)
            @items = items
          end

          def etag
            items.max_by(&:etag).etag unless items.empty?
          end

          def last_modified
            items.max_by(&:last_modified).last_modified unless items.empty?
          end
        end
      end
    end
  end
end
