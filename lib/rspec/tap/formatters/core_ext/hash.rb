# frozen_string_literal: true

# Extensions to the core String class
class Hash
  unless method_defined?(:compact)
    # Removes nil and blank values.
    # The value is either +NilClass+ or +String+.
    #
    # @return [Hash] compact hash
    #
    # @example
    #   { you: 0, me: nil, we: '  ' }.compact
    #   #=> { you: 0 }
    def compact
      reject { |_, value| value.nil? || value.blank? }
    end
  end

  unless method_defined?(:transform_keys)
    # Transforms hash keys.
    # The value is either +NilClass+ or +String+.
    #
    # @return [Hash] with transformed keys
    #
    # @example
    #   { you: 0, me: nil, we: '  '}.transform_keys(&:upcase)
    #   #=> { YOU: 0, ME: nil, WE: '  '}
    def transform_keys
      return enum_for(:transform_keys) { size } unless block_given?

      new_hash = {}

      each_key { |key| new_hash[yield(key)] = self[key] }

      new_hash
    end
  end

  unless method_defined?(:stringify_keys)
    # Transforms hash keys by using +to_s+.
    # The value is either +NilClass+ or +String+.
    #
    # @return [Hash] with transformed keys
    #
    # @example
    #   { you: 0, me: nil, we: '  '}.stringify_keys
    #   #=> { "you" => 0, "me" => nil, "we" => '  '}
    def stringify_keys
      transform_keys(&:to_s)
    end
  end
end
