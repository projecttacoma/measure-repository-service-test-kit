# frozen_string_literal: true


module MeasureRepositoryServiceTestKit
  # Utility functions in support of all test groups
  module GeneralUtils
    # rubocop:disable Metrics/CyclomaticComplexity
    def resource_has_matching_identifier?(resource, identifier)
      sys, value = split_identifier(identifier)
      resource.identifier.any? do |iden|
        does_match = true
        does_match &&= iden.value == value if !iden.value.nil? && value
        does_match &&= iden.system == sys if !iden.system.nil? && sys
        does_match
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    # rubocop:disable Metrics/MethodLength
    def split_identifier(identifier)
      iden_split = identifier.split('|')
      value = sys = nil
      if iden_split.length == 1
        value = iden_split[0]
      elsif iden_split[0] == ''
        value = iden_split[1]
      elsif iden_split[1] == ''
        sys = iden_split[0]
      else
        sys = iden_split[0]
        value = iden_split[1]
      end
      [sys, value]
    end
    # rubocop:enable Metrics/MethodLength
  end
end
