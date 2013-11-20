require "rack/cache"
require "sinatra"
require "slim"
require "yajl"

require_relative "descendable"
require_relative "token"

module Media
  module Web
    module Controllers
      class Base < Sinatra::Base
        extend Descendable

        UUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

        set(:authenticator) { raise NotImplementedError }
        set(:authorizer)    { Authorizers::Base }
        set(:directory)     { raise NotImplementedError }
        set(:model)         { raise NotImplementedError }
        set(:namespace)     { name.split("::").last.downcase }
        set(:parameters)    { Parameters::Base }
        set(:pattern)       { UUID }
        set(:presenter)     { Presenters::Base }
        set(:provides)      { %w(application/json) }
        set(:scoper)        { authorizer::Scope }

        use Rack::Cache,
          metastore:   ENV["RACK_CACHE_META"],
          entitystore: ENV["RACK_CACHE_ENTITY"],
          verbose:     ENV["DEBUG"]
        use Rack::Deflater

        class << self

          def crud
            index
            create
            show
            update
            destroy
          end

          def static
            index
            show
          end

          def index
            get "/" do
              return 403 unless authorize.index?

              preconditions(collection)
              respond_with :index, locals: { collection: present(collection) }
            end
          end

          def create
            post "/" do
              item.set_fields(params.merge(parameters.upload.to_h),
                authorize.fields, missing: :skip)

              return 403 unless authorize.create?

              if item.save
                headers["Location"] = url(item.id)
                preconditions(item)
                status 201
                respond_with :show, locals: { item: present(item) }
              else
                status 400
                respond_with :error
              end
            end
          end

          def show
            get %r{/(?<id>#{pattern})} do
              not_found unless item?
              preconditions(item)

              return 403 unless authorize.show?

              respond_with :show, locals: { item: present(item) }
            end
          end

          def download
            not_found unless item?
            preconditions(item)

            get %r{/(?<id>#{pattern})/download} do
              return 403 unless authorize.download?

              send_file item.file, filename: item.name
            end
          end

          def update
            put %r{/(?<id>#{pattern})} do
              not_found unless item?
              preconditions(item)

              item.set_fields(params, authorize.fields, missing: :skip)

              return 403 unless authorize.update?

              if item.save or not item.modified?
                preconditions(item)
                respond_with :show, locals: { item: present(item) }
              else
                status 400
                respond_with :error
              end
            end
          end

          def destroy
            delete %r{/(?<id>#{pattern})} do
              not_found unless item?
              preconditions(item)

              return 403 unless authorize.destroy?

              if item.destroy
                204
              else
                400
              end
            end
          end
        end

        def authentication
          self.class.authenticator[token]
        end

        def authorization
          self.class.authorizer.new(user, item)
        end

        def user
          self.class.directory[authentication.person_id]
        end

        def scope
          self.class.scoper.call(user, self.class.model)
        end

        def collection
          scope
        end

        def item
          @item ||= parameters.id ? self.class.model[parameters.id] : self.class.model.new
        end

        def item?
          parameters.id and item
        end

        def preconditions(obj)
          etag          present(obj).etag
          last_modified present(obj).last_modified
        end

        def present(obj)
          self.class.presenter.create(self, obj)
        end

        def parameters
          self.class.parameters.new(params, pattern: self.class.pattern)
        end

        def token
          Token.new(request)
        end

        private

        def find_template(views, name, engine, &block)
          views = Pathname(views)

          [views, views + self.class.namespace, views + "base"].each do |path|
            super(path, name, engine, &block)
          end
        end

        def respond_with(template, options = {})
          renderer = case request.preferred_type(self.class.provides)
          when "application/json" then :yajl
          when "text/html" then :slim
          else halt 406
          end

          send(renderer, template, options)
        end
      end
    end
  end
end
