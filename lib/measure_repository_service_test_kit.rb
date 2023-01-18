# frozen_string_literal: true

require_relative 'measure_repository_service_test_kit/measure_group'
require_relative 'measure_repository_service_test_kit/library_group'
require_relative 'measure_repository_service_test_kit/measure_package'
require_relative 'measure_repository_service_test_kit/library_package'

module MeasureRepositoryServiceTestKit
  # Overall test suite
  class Suite < Inferno::TestSuite
    id :measure_repository_service_test_suite
    title 'Measure Repository Service Test Suite'
    description 'A set of tests for Measure Repository Service\'s operations and resources'

    # These inputs will be available to all tests in this suite
    input :url,
          title: 'FHIR Server Base Url'

    input :credentials,
          title: 'OAuth Credentials',
          type: :oauth_credentials,
          optional: true

    # All FHIR requests in this suite will use this FHIR client
    fhir_client do
      url :url
      oauth_credentials :credentials
    end

    # All FHIR validation requsets will use this FHIR validator
    validator do
      url ENV.fetch('VALIDATOR_URL')
    end

    # Tests and TestGroups can be defined inline
    group do
      id :capability_statement
      title 'Capability Statement'
      description 'Verify that the server has a CapabilityStatement'

      test do
        id :capability_statement_read
        title 'Read CapabilityStatement'
        description 'Read CapabilityStatement from /metadata endpoint'

        run do
          fhir_get_capability_statement
          assert_response_status(200)
          assert_resource_type(:capability_statement)
        end
      end
    end

    # Tests and TestGroups from separate files (included using their id)
    group from: :measure_group
    group from: :library_group
    group from: :measure_package
    group from: :library_package
  end
end
