module DataMapper
  # This class has dubious semantics and we only have it so that people can write
  # params[:key] instead of params['key'].
  class Mash < Hash

    # Initializes a new mash.
    #
    # @param [Hash, Object] constructor
    #   The default value for the mash. If +constructor+ is a Hash, a new mash
    #   will be created based on the keys of the hash and no default value will
    #   be set.
    def initialize(constructor = {})
      if constructor.is_a?(Hash)
        super()
        update(constructor)
      else
        super(constructor)
      end
    end

    # Gets the default value for the mash.
    #
    # @param [Object] key
    #   The default value for the mash. If +key+ is a Symbol and it is a key in
    #   the mash, then the default value will be set to the value matching the
    #   key.
    def default(key = nil)
      if key.is_a?(Symbol) && include?(key = key.to_s)
        self[key]
      else
        super
      end
    end

    alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
    alias_method :regular_update, :update unless method_defined?(:regular_update)

    # Sets the +value+ associated with the specified +key+.
    #
    # @param [Object] key The key to set.
    # @param [Object] value The value to set the key to.
    def []=(key, value)
      regular_writer(convert_key(key), convert_value(value))
    end

    # Updates the mash with the key/value pairs from the specified hash.
    #
    # @param [Hash] other_hash
    #   A hash to update values in the mash with. The keys and the values will be
    #   converted to Mash format.
    #
    # @return [Mash] The updated mash.
    def update(other_hash)
      other_hash.each_pair { |key, value| regular_writer(convert_key(key), convert_value(value)) }
      self
    end

    alias_method :merge!, :update

    # Determines whether the mash contains the specified +key+.
    #
    # @param [Object] key The key to check for.
    # @return [Boolean] True if the key exists in the mash.
    def key?(key)
      super(convert_key(key))
    end

    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?

    # @param [Object] key The key to fetch.
    # @param [Array] *extras Default value.
    #
    # @return [Object] The value at key or the default value.
    def fetch(key, *extras)
      super(convert_key(key), *extras)
    end

    # @param [Array] *indices
    #   The keys to retrieve values for.
    #
    # @return [Array] The values at each of the provided keys.
    def values_at(*indices)
      indices.collect {|key| self[convert_key(key)]}
    end

    # @param [Hash] hash The hash to merge with the mash.
    #
    # @return [Mash] A new mash with the hash values merged in.
    def merge(hash)
      self.dup.update(hash)
    end

    # @param [Object] key The key to delete from the mash.
    def delete(key)
      super(convert_key(key))
    end

    # Returns a mash that includes everything but the given +keys+.
    #
    # @param [Array<String, Symbol>] *keys The mash keys to exclude.
    #
    # @return [Mash] A new mash without the selected keys.
    #
    # @example
    #   { :one => 1, :two => 2, :three => 3 }.except(:one)
    #     #=> { "two" => 2, "three" => 3 }
    def except(*keys)
      self.dup.except!(*keys.map {|k| convert_key(k)})
    end

    # Removes the specified +keys+ from the mash.
    #
    # @param [Array] *keys The mash keys to exclude.
    #
    # @return [Hash] +hash+
    #
    # @example
    #   mash = { :one => 1, :two => 2, :three => 3 }
    #   mash.except!(:one, :two)
    #   mash # => { :three => 3 }
    def except!(*keys)
      keys.each { |key| delete(key) }
      self
    end

    # Used to provide the same interface as Hash.
    #
    # @return [Mash] This mash unchanged.
    def stringify_keys!; self end

    # @return [Hash] The mash as a Hash with symbolized keys.
    def symbolize_keys
      h = Hash.new(default)
      each { |key, val| h[key.to_sym] = val }
      h
    end

    # @return [Hash] The mash as a Hash with string keys.
    def to_hash
      Hash.new(default).replace(self)
    end

    protected
    # @param [Object] key The key to convert.
    #
    # @param [Object]
    #   The converted key. If the key was a symbol, it will be converted to a
    #   string.
    #
    # @api private
    def convert_key(key)
      key.kind_of?(Symbol) ? key.to_s : key
    end

    # @param [Object] value The value to convert.
    #
    # @return [Object]
    #   The converted value. A Hash or an Array of hashes, will be converted to
    #   their Mash equivalents.
    #
    # @api private
    def convert_value(value)
      if value.class == Hash
         mash = Mash.new(value)
         mash.default = value.default
         mash
      elsif value.is_a?(Array)
        value.collect { |e| convert_value(e) }
      else
        value
      end
    end
  end
end
