# frozen_string_literal: true

# Extensions to the core String class
class String
  unless method_defined?(:blank?)
    # Checks whether a string is blank. A string is considered blank if it
    # is either empty or contains only whitespaces.
    #
    # @return [Boolean] true is the string is blank, false otherwise
    #
    # @example
    #   ''.blank?
    #   #=> true
    #
    # @example
    #   '  '.blank?
    #   #=> true
    #
    # @example
    #   '  abc  '.blank?
    #   #=> false
    def blank?
      empty? || strip.empty?
    end
  end

  unless method_defined?(:present?)
    # Checks whether a string is present. A string is considered present if it
    # is not blank.
    #
    # @return [Boolean] true is the string is present, false otherwise
    #
    # @example
    #   ''.present?
    #   #=> false
    #
    # @example
    #   '  '.present?
    #   #=> false
    #
    # @example
    #   '  abc  '.present?
    #   #=> true
    def present?
      !blank?
    end
  end
end
