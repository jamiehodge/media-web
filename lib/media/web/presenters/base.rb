require "digest/md5"

module Media
  module Web
    module Presenters
      class Base

        attr_reader :context, :item

        def self.create(context, obj)
          if obj.respond_to?(:id)
            new(context, obj)
          else
            Collection.new obj.map {|o| new(context, o) }
          end
        end

        def initialize(context, item)
          @context = context
          @item = item
        end

        def etag
          Digest::MD5.hexdigest([item.id, item.lock_version].join("-"))
        end

        def last_modified
          item.updated_at
        end

        def method_missing(method, *params, &block)
          item.send(method, *params, &block)
        end

        def respond_to?(symbol, include_all=false)
          super || item.respond_to?(symbol, include_all)
        end

        private

        class Collection
          include Enumerable

          attr_reader :items

          def initialize(items)
            @items = items
          end

          def each(&blk)
            items.each(&blk)
          end

          def etag
            Digest::MD5.hexdigest(items.map(&:etag).join)
          end

          def last_modified
            items.max_by(&:last_modified).last_modified unless items.empty?
          end
        end
      end
    end
  end
end
