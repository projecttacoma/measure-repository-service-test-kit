# frozen_string_literal: true

module MeasureRepositoryServiceTestKit
  # Utility functions in support of the data requirements test group
  module DataRequirementsUtils
    def get_filter_str(code_filter)
      ret_val = '(no code filter)'

      if code_filter&.code&.first
        code = code_filter.code.first
        ret_val = "(#{code.system}|#{code.code})"
      elsif code_filter&.valueSet
        ret_val = "(#{code_filter.valueSet})"
      end

      ret_val
    end

    def get_dr_comparison_list(data_requirement)
      data_requirement.map do |dr|
        cf = dr.codeFilter&.first
        filter_str = get_filter_str cf

        path = cf&.path ? ".#{cf.path}" : ''

        "#{dr.type}#{path}#{filter_str}"
      end
    end
  end
end
