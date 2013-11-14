require "rack/cache"
require "sinatra"
require "slim"
require "yajl"

require_relative "descendable"

module Media
  module Web
    module Controllers
      class Base < Sinatra::Base
        extend Descendable

        set(:authenticator) { Authenticators::Base }
        set(:headers)       { Headers::Base }
        set(:model)         { raise NotImplementedError }
        set(:namespace)     { name.split("::").last.downcase }
        set(:parameters)    { Parameters::Base }
        set(:policy)        { Policies::Base }
        set(:presenter)     { Presenters::Base }
        set(:provides)      { %w(application/json) }

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

          def index
            get "/" do
              return 403 unless authorize.index?

              etag          present(collection).etag
              last_modified present(collection).last_modified

              respond_with :index, locals: { collection: present(collection) }
            end
          end

          def create
            post "/" do
              item.set_fields(params, authorize.fields, missing: :skip)

              return 403 unless authorize.create?

              if item.save
                headers["Location"] = url(item.id)

                status 201

                etag          present(item).etag
                last_modified present(item).last_modified

                respond_with :show, locals: { item: present(item) }
              else
                status 400
                respond_with :error
              end
            end
          end

          def show
            get "/:id" do
              return 403 unless authorize.show?

              respond_with :show, locals: { item: present(item) }
            end
          end

          def update
            put "/:id" do
              item.set_fields(params, authorize.fields, missing: :skip)

              return 403 unless authorize.update?

              if item.save or not item.modified?
                etag          present(item).etag
                last_modified present(item).last_modified

                respond_with :show, locals: { item: present(item) }
              else
                status 400
                respond_with :error
              end
            end
          end

          def destroy
            delete "/:id" do
              return 403 unless authorize.destroy?

              if item.destroy
                204
              else
                400
              end
            end
          end
        end

        before "/:id" do
          not_found unless parameters.id and item

          etag          present(item).etag
          last_modified present(item).last_modified
        end

        def authenticate
          self.class.authenticator.new(self, nil)
        end

        def authorize
          self.class.policy.new(authenticate.person_id, item)
        end

        def collection
          @collection ||= authorize.collection
        end

        def find_template(views, name, engine, &block)
          views = Pathname(views)

          [views, views + self.class.namespace, views + "base"].each do |path|
            super(path, name, engine, &block)
          end
        end

        def item
          @item ||= begin
            if id = parameters.id
              self.class.model[id]
            else
              self.class.model.new
            end
          end
        end

        def parameters
          self.class.parameters.new(params)
        end

        def present(obj)
          self.class.presenter.create(self, obj)
        end

        def request_headers
          self.class.headers.new(request)
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
