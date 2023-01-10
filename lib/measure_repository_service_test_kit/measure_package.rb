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
      input :selected_measure_id
      makes_request :measure_package
      run do
        fhir_operation("Measure/#{selected_measure_id}/$package", name: :measure_package)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(measure_in_bundle(selected_measure_id, 'id', resource))
      end
    end

    test do
      title '200 response and JSON Bundle body for POST by url in body'
      id 'measure-package-02'
      description 'returned response has status code 200 and valid JSON FHIR Bundle in body'
      input :selected_measure_url
      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            {	name: 'identifier',
              valueUrl: selected_measure_url }
          ]
        }
        params = FHIR::Parameters.new params_hash

        fhir_operation("Measure/$package", body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(measure_in_bundle(selected_measure_url, 'url', resource))
      end
    end

    test do
      title '200 response and JSON Bundle body for POST by url in body'
      id 'measure-package-02'
      description 'returned response has status code 200 and valid JSON FHIR Bundle in body'
      input :selected_measure_url
      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            {	name: 'url',
              valueUrl: selected_measure_url }
          ]
        }
        params = FHIR::Parameters.new params_hash

        fhir_operation("Measure/$package", body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(measure_in_bundle(selected_measure_url, 'url', resource))
      end
    end

    test do
      title 'All related artifacts present'
      id 'measure-package-03'
      description 'returned bundle includes all related artifacts for all libraries'
      input :selected_measure_id
      uses_request :measure_package
      run do
        assert(related_artifacts_present(resource))
      end
    end
  end
end
