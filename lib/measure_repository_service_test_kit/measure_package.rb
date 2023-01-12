# frozen_string_literal: true

require 'json'
require_relative '../utils/package_utils'

module MeasureRepositoryServiceTestKit
  # tests for Measure $package service
  class MeasurePackage < Inferno::TestGroup
    include PackageUtils

    title 'Measure $package'
    description 'Ensure measure repository service can execute the $package operation to the Measure endpoint'
    id 'measure_package'

    fhir_client do
      url :url
    end

    test do
      title '200 response and JSON Bundle body for POST by id in url'
      id 'measure-package-01'
      description 'returned response has status code 200 and valid JSON FHIR Bundle in body'
      input :measure_id , title: 'Measure id' 
      makes_request :measure_package
      run do
        fhir_operation("Measure/#{measure_id}/$package", name: :measure_package)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_id, 'id', resource)
        assert(!measure.nil?)
      end
    end

    # rubocop:disable Metrics/BlockLength
    test do
      title '200 response and JSON Bundle body for POST by url, identifier, and version in body'
      id 'measure-package-02'
      description 'returned response has status code 200 and included Measure matches url, identifier, and version'
      input :measure_url, title: 'Measure url' 
      input :measure_identifier, title: 'Measure identifier' 
      input :measure_version, title: 'Measure version' 

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            {	name: 'url',
              valueUrl: measure_url },
            {	name: 'identifier',
              valueString: measure_identifier },
            { name: 'version',
              valueString: measure_version }
          ]
        }
        params = FHIR::Parameters.new params_hash

        fhir_operation('Measure/$package', body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_url, 'url', resource)
        assert(!measure.nil?)
        assert(measure_has_identifier?(measure, measure_identifier))
        assert(measure.version == measure_version)
      end
    end
    # rubocop:enable Metrics/BlockLength

    test do
      title 'All related artifacts present'
      id 'measure-package-03'
      description 'returned bundle includes all related artifacts for all libraries'
      input :measure_id, title: 'Measure id' 
      uses_request :measure_package
      run do
        assert(related_artifacts_present?(resource))
      end
    end

    test do
      title 'Throws 404 when no Measure on server matches id'
      id 'measure-package-04'
      description 'returns 404 status code with OperationOutcome when no Measure exists with passed-in id'

      run do
        fhir_operation('Measure/INVALID_ID/$package')
        assert_response_status(404)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end

    test do
      title 'Throws 400 when no id, url, or identifier provided'
      id 'measure-package-05'
      description 'returns 400 status code with OperationOutcome when no id or url provided'

      run do
        fhir_operation('Measure/$package')
        assert_response_status(400)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end
  end
end
