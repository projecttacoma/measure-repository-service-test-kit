# frozen_string_literal: true

require 'json'
require_relative '../utils/assertion_utils'

module MeasureRepositoryServiceTestKit
  # tests for read by ID and search for Measure service
  # rubocop:disable Metrics/ClassLength
  class MeasureDataRequirements < Inferno::TestGroup
    # module for shared code for $data-requirements assertions and requests
    module DataRequirementsHelpers
      def assert_dr_failure(expected_status: 400)
        assert_error(expected_status)
      end

      def assert_dr_success
        assert_success(:library, 200)
        assert(!resource.type.coding.find { |c| c.code == 'module-definition' }.nil?)
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
      title 'Check $data-requirements with id returns 200'
      id 'data-requirements-01'
      description '$data-requirements returns 200OK and Library of type module-definition when given Measure id'
      input :measure_id, title: 'Measure id'

      run do
        fhir_operation("Measure/#{measure_id}/$data-requirements",
                       body: PARAMS)
        assert_dr_success
      end
    end

    test do
      include DataRequirementsHelpers
      title 'Check $data-requirements with url returns 200'
      id 'data-requirements-02'
      description '$data-requirements returns 200OK and Library of type module-definition when passed in a url'
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
        assert_dr_success
      end
    end

    test do
      include DataRequirementsHelpers
      title 'Check $data-requirements with identifier returns 200'
      id 'data-requirements-03'
      description '$data-requirements returns 200OK and Library of type module-definition when passed in an identifier'
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

        assert_dr_success
      end
    end

    test do
      include DataRequirementsHelpers
      title 'Check $data-requirements accepts periodStart and periodEnd parameters'
      id 'data-requirements-04'
      description '$data-requirements returns 200 when passed periodStart and periodEnd parameters'
      input :measure_id, title: 'Measure id'

      run do
        fhir_operation(
          "Measure/#{measure_id}/$data-requirements?periodStart=2019-01-01&periodEnd=2020-01-01",
          body: PARAMS
        )
        assert_dr_success
      end
    end

    test do
      include DataRequirementsHelpers
      title 'Check $data-requirements returns 404 for invalid measure id'
      id 'data-requirements-05'
      description '$data-requirements returns 404 when passed a measure id which is not in the system'

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
      title 'Check $data-requirements returns 400 for no identification info'
      id 'data-requirements-06'
      description '$data-requirements returns 404 when passed a measure id which is not in the system'

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
      title 'Check $data-requirements returns 400 for invalid parameter'
      id 'data-requirements-07'
      description '$data-requirements returns 400 when passed an invalid parameter'

      run do
        fhir_operation(
          "Measure/#{INVALID_ID}/$data-requirements?invalid=false",
          body: PARAMS
        )
        assert_dr_failure(expected_status: 400)
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
