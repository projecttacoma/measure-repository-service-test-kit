# frozen_string_literal: true

module MeasureRepositoryServiceTestKit
  # module for shared code for $data-requirements assertions and requests
  module DataRequirementsUtils
    def assert_dr_failure(expected_status: 400)
      assert_error(expected_status)
    end

    def assert_dr_success
      assert_success(:library, 200)
      assert(!resource.type.coding.find { |c| c.code == 'module-definition' }.nil?)
    end
  end
end
