module ActiveRecord
  module ConnectionAdapters
    class ConnectionPool
      def cleanup_connection
        return yield if Thread.current[:__AR__cleanup_connection]

        begin
          Thread.current[:__AR__cleanup_connection] = true
          yield
        ensure
          release_connection
          Thread.current[:__AR__cleanup_connection] = false
        end
      end
    end
  end

  class Base
    class << self
      def cleanup_connection(&block)
        connection_pool.cleanup_connection(&block)
      end

      # comment out this redefinition once you've wrapped all necessary methods
      alias_method :connection_without_cleanup_connection_check, :connection
      def connection(*a)
        if ! Thread.current[:__AR__cleanup_connection]
          puts "connection called outside of cleanup_connection block", caller, "\n"
        end
        connection_without_cleanup_connection_check(*a)
      end
    end
  end
end

methods_to_wrap = {
  (class<<ActiveRecord::Base;self;end) => [
    :find, :find_every, :find_by_sql, :transaction, :count, :create, :delete, :count_by_sql,
    :update, :destroy, :cache, :uncached, :quoted_table_name, :columns, :exists?, :update_all,
    :increment_counter, :decrement_counter, :delete_all, :table_exists?, :update_counters, 
  ],
  ActiveRecord::Base => [:quoted_id],
  ActiveRecord::Associations::AssociationCollection => [:initialize, :find, :find_target, :load_target],
  ActiveRecord::Associations::HasAndBelongsToManyAssociation => [:create],
  ActiveRecord::Associations::HasManyThroughAssociation => [:construct_conditions],
  ActiveRecord::Associations::HasOneAssociation => [:construct_sql],
  ActiveRecord::Associations::ClassMethods => [:collection_reader_method, :configure_dependency_for_has_many],
  ActiveRecord::Calculations::ClassMethods => [:calculate],
}
methods_to_wrap[Test::Unit::TestSuite] = [:run]  if defined?(Test::Unit::TestSuite)

methods_to_wrap.each do |klass, methods|
  methods.each do |method|
    klass.class_eval do
      alias_method_chain method, :cleanup_connection do |target, punc|
        eval %{
          def #{target}_with_cleanup_connection#{punc}(*a, &b)
            ActiveRecord::Base.connection_pool.cleanup_connection do
              #{target}_without_cleanup_connection#{punc}(*a, &b)
            end
          end
        }
      end
    end
  end
end
