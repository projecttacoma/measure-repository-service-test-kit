# frozen_string_literal: true

require 'json'
require_relative '../utils/package_utils'

module MeasureRepositoryServiceTestKit
  # tests for include-terminology functionality for Measure $package service
  # rubocop:disable Metrics/ClassLength
  class MeasureIncludeTerminology < Inferno::TestGroup
    include PackageUtils

    title 'Measure include terminology $package'
    description 'Ensure measure repository service can execute the $package
    operation to the Measure endpoint with include-terminology query parameter'
    id 'measure_include_terminology'

    fhir_client do
      url :url
    end

    test do
      optional
      title '200 response and JSON Bundle body including measure reasource for POST by id in url'
      id 'measure-include-terminology-01'
      description 'returned response has status code 200 and valid JSON FHIR Bundle
      including Measure resource and valueset resources in body and include-terminology=true'
      input :measure_id, title: 'Measure id'
      makes_request :measure_package_include_terminology
      run do
        fhir_operation("Measure/#{measure_id}/$package?include-terminology=true",
                       name: :measure_package_include_terminology)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_id, 'id', resource)
        assert(!measure.nil?, "No Measure found in bundle with id: #{measure_id}")
      end
    end

    test do
      optional
      title '200 response and JSON Bundle body for POST with url in body'
      id 'measure-include-terminology-02'
      description 'returned response has status code 200 and included Measure matches url parameter
      and include-terminology=true'
      input :measure_url, title: 'Measure url'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            { name: 'url',
              valueUrl: measure_url }
          ]
        }.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation('Measure/$package?include-terminology=true', body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_url, 'url', resource)
        assert(!measure.nil?, "No Measure found in bundle with url: #{measure_url}")
      end
    end

    test do
      optional
      title '200 response and JSON Bundle body for POST with identifier in body'
      id 'measure-include-terminology-03'
      description 'returned response has status code 200 and included Measure matches identifier
      parameter and include-terminology=true.'
      input :measure_identifier, title: 'Measure Identifier'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            { name: 'identifier',
              valueString: measure_identifier }
          ]
        }.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation('Measure/$package?include-terminology=true', body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_identifier, 'identifier', resource)
        assert(!measure.nil?, "No Measure found in bundle with identifier: #{measure_identifier}")
      end
    end

    # rubocop:disable Metrics/BlockLength
    test do
      optional
      title '200 response and JSON Bundle body for POST parameters url, identifier, and version in body and id in url'
      id 'measure-include-terminology-04'
      description 'returned response has status code 200 and included Measure matches parameters url,
        identifier, and version with include-terminology=true. Verifies the server supports SHALL parameters
        for the operation'
      input :measure_id, title: 'Measure id'
      input :measure_url, title: 'Measure url'
      input :measure_identifier, title: 'Measure identifier'
      input :measure_version, optional: true, title: 'Measure version'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            { name: 'url',
              valueUrl: measure_url },
            { name: 'identifier',
              valueString: measure_identifier }
          ]
        }
        unless measure_version.nil?
          params_hash[:parameter].append({ name: 'version',
                                           valueString: measure_version })
        end

        params_hash.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation("Measure/#{measure_id}/$package?include-terminology=true", body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_url, 'url', resource)
        assert(!measure.nil?)
        assert(measure.id == measure_id,
               "No Measure found in bundle with id: #{measure_id}")
        assert(measure_has_matching_identifier?(measure, measure_identifier),
               "No Measure found in bundle with idendifier: #{measure_identifier}")
        unless measure_version.nil?
          assert(measure.version == measure_version,
                 "No Measure found in bundle with version: #{measure_version}")
        end
      end
    end
    # rubocop:enable Metrics/BlockLength

    test do
      optional
      title 'All related artifacts present including valuesets'
      id 'measure-include-terminology-05'
      description 'returned bundle inludes all artifacts for all libraries
      including valuesets with include-terminology=true'
      input :measure_id, title: 'Measure id'
      uses_request :measure_package_include_terminology
      run do
        assert(related_artifacts_present?(resource))
        assert(related_valuesets_present?(resource))
      end
    end

    test do
      optional
      title 'Throws 404 when no Measure on server matches id'
      id 'measure-include-terminology-06'
      description 'returns 404 status code with OperationOutcome when no Measure exists with
      passed-in id and include-terminology=true'

      run do
        fhir_operation('Measure/INVALID_ID/$package?include-terminology=true')
        assert_response_status(404)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end

    test do
      optional
      title 'Throws 400 when no id, url, or identifier provided'
      id 'measure-include-terminology-07'
      description 'returns 400 status code with OperationOutcome when no id, url, or identifier
      provided and include-terminology=true'

      run do
        fhir_operation('Measure/$package?include-terminology=true')
        assert_response_status(400)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
