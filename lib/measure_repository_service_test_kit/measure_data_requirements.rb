# frozen_string_literal: true

require 'json'
require_relative '../utils/assertion_utils'
require_relative '../utils/data_requirements_utils'

module MeasureRepositoryServiceTestKit
  # tests for $data-requirements operation for Measure service
  # rubocop:disable Metrics/ClassLength
  class MeasureDataRequirements < Inferno::TestGroup
    title 'Measure $data-requirements'
    description 'Ensure measure repository service can run Measure/$data-requirements operation'
    id 'measure_data_requirements'
    custom_headers = { 'content-type': 'application/fhir+json' }

    fhir_client do
      url :url
      headers custom_headers
    end

    INVALID_ID = 'INVALID_ID'

    test do
      include DataRequirementsUtils
      title 'Check $data-requirements with id returns 200'
      id 'data-requirements-01'
      description '$data-requirements returns 200OK and Library of type module-definition when given Measure id'
      input :measure_id, title: 'Measure id'

      run do
        fhir_operation("Measure/#{measure_id}/$data-requirements")

        assert_dr_success
      end
    end

    test do
      include DataRequirementsUtils
      title 'Check $data-requirements with url returns 200'
      id 'data-requirements-02'
      description '$data-requirements returns 200OK and Library of type module-definition when passed in a Measure url'
      input :measure_url, title: 'Measure url'
      input :measure_version, optional: true, title: 'Measure version'

      run do
        url_params_hash = {
          resourceType: 'Parameters',
          parameter: [{
            name: 'url',
            valueUrl: measure_url
          }]
        }

        unless measure_version.nil?
          url_params_hash[:parameter].append({ name: 'version',
                                               valueString: measure_version })
        end

        url_params_hash = url_params_hash.freeze
        url_params = FHIR::Parameters.new url_params_hash

        fhir_operation('Measure/$data-requirements',
                       body: url_params)

        assert_dr_success
      end
    end

    test do
      include DataRequirementsUtils
      title 'Check $data-requirements with identifier returns 200'
      id 'data-requirements-03'
      description '$data-requirements returns 200OK and Library of type module-definition
    when passed in a Measure identifier'
      input :measure_identifier, title: 'Measure identifier'
      run do
        identifier_params_hash = {
          resourceType: 'Parameters',
          parameter: [{
            name: 'identifier',
            valueUrl: measure_identifier
          }]
        }.freeze

        identifier_params = FHIR::Parameters.new identifier_params_hash

        fhir_operation('Measure/$data-requirements',
                       body: identifier_params)

        assert_dr_success
      end
    end

    test do
      include DataRequirementsUtils
      title 'Check $data-requirements accepts periodStart and periodEnd parameters'
      id 'data-requirements-04'
      description '$data-requirements returns 200 when passed periodStart and periodEnd parameters'
      input :measure_id, title: 'Measure id'

      run do
        fhir_operation(
          "Measure/#{measure_id}/$data-requirements?periodStart=2023-01-01&periodEnd=2023-12-31"
        )

        assert_dr_success
      end
    end

    test do
      include DataRequirementsUtils
      title 'Throws 404 error when no measure on the server matches id'
      id 'data-requirements-05'
      description '$data-requirements returns 404 when passed a measure id which is not in the system'

      run do
        fhir_operation(
          "Measure/#{INVALID_ID}/$data-requirements"
        )

        assert_dr_failure(expected_status: 404)
      end
    end

    test do
      include DataRequirementsUtils
      title 'Check $data-requirements returns 400 for no identification info'
      id 'data-requirements-06'
      description '$data-requirements returns 400 when no id, url, or identifier parameter included'

      run do
        fhir_operation(
          'Measure/$data-requirements'
        )

        assert_dr_failure
      end
    end

    test do
      include DataRequirementsUtils
      title 'Check $data-requirements returns 400 for invalid parameter'
      id 'data-requirements-07'
      description '$data-requirements returns 400 when passed an invalid parameter'
      input :measure_id, title: 'Measure id'

      run do
        fhir_operation(
          "Measure/#{measure_id}/$data-requirements?invalid=false"
        )

        assert_dr_failure
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
