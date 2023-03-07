# frozen_string_literal: true

module MeasureRepositoryServiceTestKit
  # module for shared code for $data-requirements assertions and requests
  module DataRequirementsUtils
    def assert_dr_failure(expected_status: 400)
      assert_error(expected_status)
    end

    def assert_dr_success
      assert_success(:library, 200)
      assert(resource.dataRequirement, 'No data requirement created.')
      assert(!resource.type.coding.find do |c|
               c.code == 'module-definition'
             end.nil?, 'Resulting data requirements Library is not type module-definition')
    end
  end
end
