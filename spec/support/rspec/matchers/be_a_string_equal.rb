# frozen_string_literal: true

RSpec::Matchers.define :be_a_string_equal do |expected|
  match do |actual|
    actual.is_a?(String) && expected.is_a?(String) && actual == expected
  end

  description do
    "a string equal to '#{expected}'"
  end

  failure_message do |actual|
    "expected '#{actual}' to be '#{expected}'"
  end

  failure_message_when_negated do |actual|
    "expected '#{actual}' not to be '#{expected}'"
  end
end

RSpec::Matchers.alias_matcher :a_string_equal_to, :be_a_string_equal
