# frozen_string_literal: true

class String
  unless method_defined?(:blank?)
    def blank?
      empty? || strip.empty?
    end
  end

  unless method_defined?(:present?)
    def present?
      !blank?
    end
  end
end
