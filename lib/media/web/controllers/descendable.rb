module Media
  module Web
    module Controllers
      module Descendable

        def inherited(subclass)
          super
          children << subclass
        end

        def children
          @children ||= []
        end

        def [](name)
          children.detect {|child| child.namespace == name }
        end
      end
    end
  end
end
