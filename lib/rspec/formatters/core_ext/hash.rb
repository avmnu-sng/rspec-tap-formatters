# frozen_string_literal: true

class Hash
  unless method_defined?(:compact)
    def compact
      reject { |_, value| value.nil? || value.blank? }
    end
  end

  unless method_defined?(:transform_keys)
    def transform_keys
      return enum_for(:transform_keys) { size } unless block_given?

      new_hash = {}

      each_key { |key| new_hash[yield(key)] = self[key] }

      new_hash
    end
  end

  unless method_defined?(:stringify_keys)
    def stringify_keys
      transform_keys(&:to_s)
    end
  end
end
