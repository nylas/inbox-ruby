module Nylas
  module V2
    class Collection
      attr_accessor :model, :api, :constraints
      def initialize(model: , api: , constraints: nil)
        self.constraints = Constraints.from_constraints(constraints)
        self.model = model
        self.api = api
      end

      def new(**attributes)
        model.from_hash(attributes, api: api)
      end

      def create(**attributes)
        instance = model.from_hash(attributes, api: api)
        instance.save
        instance
      end

      def where(filters)
        self.class.new(model: model, api: api, constraints: constraints.merge(where: filters))
      end

      def count
        self.class.new(model: model, api: api, constraints: constraints.merge(view: "count")).execute[:count]
      end

      def first
        model.from_hash(execute.first, api: api)
      end

      def[](index)
        model.from_hash(execute(index), api: api)
      end

      # Iterates over a single page of results based upon current pagination settings
      def each(&block)
        return enum_for(:each) unless block_given?
        execute.each do |result|
          yield(model.from_hash(result, api: api))
        end
      end

      def map(&block)
        each.map(&block)
      end

      def limit(quantity)
        self.class.new(model: model, api: api, constraints: constraints.merge(limit: quantity))
      end

      def offset(start)
        self.class.new(model: model, api: api, constraints: constraints.merge(offset: start))
      end

      # Iterates over every result that meets the filters, retrieving a page at a time
      def find_each
        raise NotImplementedError, 'Finish this before 4.0.0'
      end

      # Retrieves a record. Nylas doesn't support where filters on GET so this will not take into
      # consideration other query constraints, such as where clauses.
      def find(id)
        instance = model.from_hash({ id: id }, api: api)
        instance.reload
        instance
      end

      # @return [Hash] Specification for request to be passed to {API#execute}
      def to_be_executed
        { method: :get, path: model.resources_path, query: constraints.to_query }
      end

      # Retrieves the data from the API for the particular constraints
      # @return [Hash,Array]
      def execute
        api.execute(to_be_executed)
      end
    end
  end
end

