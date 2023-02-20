# frozen_string_literal: true

require 'json'
require_relative '../utils/data_requirements_utils'
require_relative '../utils/assertion_utils'

module MeasureRepositoryServiceTestKit
  # tests for read by ID and search for Measure service
  class MeasureDataRequirements < Inferno::TestGroup
    include DataRequirementsUtils
    # module for shared code for $data-requirements assertions and requests
    module DataRequirementsHelpers
      def assert_dr_failure(expected_status: 400)
        assert_error(expected_status)
      end

      def assert_dr_success(resource_type)
        assert_success(resource_type, 200)
      end
    end

    title 'Measure $data-requirements'
    description 'Ensure measure repository service can run $data-requirements operation'
    id 'measure_data_requirements'

    fhir_client do
      url :url
    end

    PARAMS = {
      resourceType: 'Parameters',
      parameter: []
    }.freeze

    INVALID_ID = 'INVALID_ID'

    test do
      include DataRequirementsHelpers
      title 'Check data requirements with id against expected return'
      id 'data-requirements-01'
      description 'Data requirements on the FHIR test server match the data requirements of reference server'
      input :measure_id, title: 'Measure id'
      input :data_requirements_reference_server, title: 'Data Requirements Reference Server'

      fhir_client :dr_reference_client do
        url :data_requirements_reference_server
      end

      run do
        # Get measure resource from client
        fhir_read(:measure, measure_id)
        assert_dr_success(:measure)

        measure_url = resource.url
        measure_version = resource.version

        # Run data requirements operation on the test client server
        fhir_operation("Measure/#{measure_id}/$data-requirements",
                       body: PARAMS)

        assert_dr_success(:library)

        actual_dr = resource.dataRequirement

        actual_dr_strings = get_dr_comparison_list actual_dr

        # Search reference server by identifier and version
        fhir_search(:measure, client: :dr_reference_client,
                              params: { url: measure_url, version: measure_version }, name: :measure_search)

        assert_dr_success(:bundle)
        assert(resource.total == 1, 'matching measure not found on reference server.')

        reference_measure_id = resource.entry[0].resource.id

        # Run data requirements operation on reference server
        fhir_operation(
          "Measure/#{reference_measure_id}/$data-requirements",
          body: PARAMS,
          client: :dr_reference_client
        )
        expected_dr = resource.dataRequirement

        expected_dr_strings = get_dr_comparison_list expected_dr

        diff = expected_dr_strings - actual_dr_strings

        # Ensure both data requirements results libraries are identical
        assert(diff.blank?,
               "Client data-requirements is missing expected data requirements for measure #{measure_id}: #{diff}")

        diff = actual_dr_strings - expected_dr_strings
        assert(diff.blank?,
               "Client data-requirements contains unexpected data requirements for measure #{measure_id}: #{diff}")
      end
    end

    test do
      include DataRequirementsHelpers
      title 'Check data requirements with url returns 200OK'
      id 'data-requirements-02'
      description 'Data requirements on the FHIR test server returns 200OK and Library body when passed in a url'
      makes_request :data_requirements
      input :measure_url, title: 'Measure url'
      input :measure_version, optional: true, title: 'Measure version'

      run do
        url_params = {
          resourceType: 'Parameters',
          parameter: [{
            name: 'url',
            valueUrl: measure_url
          }]
        }

        unless measure_version.nil?
          url_params[:parameter].append({ name: 'version',
                                          valueString: measure_version })
        end

        fhir_operation('Measure/$data-requirements',
                       body: url_params)

        assert_dr_success(:library)
      end
    end

    test do
      include DataRequirementsHelpers
      title 'Check data requirements with identifier returns 200OK'
      id 'data-requirements-03'
      description 'Data requirements on the FHIR test server returns 200OK when passed in an identifier'
      makes_request :data_requirements
      input :measure_identifier, title: 'Measure identifier'
      run do
        identifier_params = {
          resourceType: 'Parameters',
          parameter: [{
            name: 'identifier',
            valueUrl: measure_identifier
          }]
        }

        fhir_operation('Measure/$data-requirements',
                       body: identifier_params)

        assert_dr_success(:library)
      end
    end

    test do
      include DataRequirementsHelpers
      title 'Check data requirements returns 404 for invalid measure id'
      id 'data-requirements-04'
      description 'Data requirements returns 404 when passed a measure id which is not in the system'

      run do
        fhir_operation(
          "Measure/#{INVALID_ID}/$data-requirements",
          body: PARAMS
        )
        assert_dr_failure(expected_status: 404)
      end
    end

    test do
      include DataRequirementsHelpers
      title 'Check data requirements returns 400 for no identification info'
      id 'data-requirements-05'
      description 'Data requirements returns 404 when passed a measure id which is not in the system'

      run do
        fhir_operation(
          'Measure/$data-requirements',
          body: PARAMS
        )
        assert_dr_failure(expected_status: 400)
      end
    end

    test do
      include DataRequirementsHelpers
      title 'Check data requirements returns 400 for invalid parameter'
      id 'data-requirements-06'
      description 'Data requirements returns 400 when passed an invalid parameter'

      run do
        fhir_operation(
          "Measure/#{INVALID_ID}/$data-requirements?invalid=false",
          body: PARAMS
        )
        assert_dr_failure(expected_status: 400)
      end
    end
  end
end
