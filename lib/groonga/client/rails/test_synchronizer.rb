module Groonga
  class Client
    module Rails
      class TestSynchronizer
        def sync(options={})
          ::Rails.application.eager_load!
          ObjectSpace.each_object(Class) do |klass|
            if klass < Searcher
              klass.sync_schema
              klass.sync_records if options[:sync_records]
            end
          end
        end
      end
    end
  end
end
