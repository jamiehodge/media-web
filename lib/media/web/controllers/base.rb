require "rack/cache"
require "rack/throttle"
require "sinatra"

module Media
  module Web
    module Controllers
      class Base < Sinatra::Base

        set(:authenticator) { Authenticator::Base }
        set(:authorizer)    { Authorizer::Base }
        set(:headers)       { Headers::Base }
        set(:model)         { raise NotImplementedError }
        set(:namespace)     { name.split("::").last.downcase }
        set(:parameters)    { Parameters::Base }
        set(:presenter)     { Presenter::Base }
        set(:responds_with) { {} }

        use Rack::Throttle::Interval, min: ENV["RACK_THROTTLE_INTERVAL"]
        use Rack::Cache,
          metastore:   ENV["RACK_CACHE_META"],
          entitystore: ENV["RACK_CACHE_ENTITY"],
          verbose:     ENV["DEBUG"]
        use Rack::Deflater

        class << self

          def index
            get "/" do
              return 401 unless authorize.index?

              etag          present(collection).etag
              last_modified present(collection).last_modified

              respond_with :index
            end
          end

          def create
            post "/" do
              item.set_fields(params, authorize.fields)

              return 401 unless authorize.create?

              if item.save
                headers["Location"] = url(item.id)

                status 201

                etag          present(item).etag
                last_modified present(item).last_modified

                respond_with :show
              else
                respond_with :error
              end
            end
          end

          def show
            get "/:id" do
              return 401 unless authorize.show?

              respond_with present(item)
            end
          end

          def update
            put "/:id" do
              item.set_fields(params, authorize.fields)

              return 401 unless authorize.update?

              if item.save or not item.modified?
                etag          present(item).etag
                last_modified present(item).last_modified

                respond_with :show
              else
                respond_with :error
              end
            end
          end

          def destroy
            delete "/:id" do
              return 401 unless authorize.destroy?

              item.destroy
              204
            end
          end
        end

        before "/:id" do
          not_found unless parameters.id and item

          etag          present(item).etag
          last_modified present(item).last_modified
        end

        private

        def authenticate
          self.class.authenticator.new(self)
        end

        def authorize
          self.class.authorizer.new(authenticate.person_id, record)
        end

        def background
          headers["rack.hijack"] = proc do |io|
            yield io
          end
        end

        def collection
          authorize.collection
        end

        def find_template(views, name, engine, &block)
          views = Pathname(views)

          [views, views + namespace, views + "base"].each do |path|
            super(path, name, engine, &block)
          end
        end

        def item
          if id = parameters.id
            self.class.model[id]
          else
            self.class.model.new
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
          renderer = self.class.responds_with[content_type] or halt 406
          send(renderer, template, options)
        end
      end
    end
  end
end
