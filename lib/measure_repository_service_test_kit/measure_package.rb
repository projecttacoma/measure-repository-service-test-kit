# frozen_string_literal: true

require 'json'
require_relative '../utils/package_utils'

module MeasureRepositoryServiceTestKit
  # tests for Measure $package service
  # rubocop:disable Metrics/ClassLength
  class MeasurePackage < Inferno::TestGroup
    include PackageUtils

    title 'Measure $package'
    description 'Ensure measure repository service can execute the $package operation to the Measure endpoint'
    id 'measure_package'

    fhir_client do
      url :url
    end

    test do
      title '200 response and JSON Bundle body including Measure resource for POST by id in url'
      id 'measure-package-01'
      description 'returned response has status code 200 and valid JSON FHIR Bundle including Measure resource in body'
      input :measure_id, title: 'Measure id'
      makes_request :measure_package
      run do
        fhir_operation("Measure/#{measure_id}/$package", name: :measure_package)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_id, 'id', resource)
        assert(!measure.nil?, "No Measure found in bundle with id: #{measure_id}")
      end
    end

    test do
      title '200 response and JSON Bundle body for POST with url in body'
      id 'measure-package-02'
      description 'returned response has status code 200 and included Measure matches url parameter.'
      input :measure_url, title: 'Measure url'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            {	name: 'url',
              valueUrl: measure_url }
          ]
        }.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation('Measure/$package', body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_url, 'url', resource)
        assert(!measure.nil?, "No Measure found in bundle with url: #{measure_url}")
      end
    end

    test do
      title '200 response and JSON Bundle body for POST with identifier in body'
      id 'measure-package-03'
      description 'returned response has status code 200 and included Measure matches identifier parameter.'
      input :measure_identifier, title: 'Measure Identifier'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            {	name: 'identifier',
              valueString: measure_identifier }
          ]
        }.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation('Measure/$package', body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_identifier, 'identifier', resource)
        assert(!measure.nil?, "No Measure found in bundle with identifier: #{measure_identifier}")
      end
    end

    # rubocop:disable Metrics/BlockLength
    test do
      title '200 response and JSON Bundle body for POST parameters url, identifier, and version in body and id in url'
      id 'measure-package-04'
      description 'returned response has status code 200 and included Measure matches parameters url,
      identifier, and version. Verifies the server supports SHALL parameters for the operation'
      input :measure_id, title: 'Measure id'
      input :measure_url, title: 'Measure url'
      input :measure_identifier, title: 'Measure identifier'
      input :measure_version, optional: true, title: 'Measure version'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            {	name: 'url',
              valueUrl: measure_url },
            {	name: 'identifier',
              valueString: measure_identifier }
          ]
        }
        unless measure_version.nil?
          params_hash[:parameter].append({ name: 'version',
                                           valueString: measure_version })
        end

        params_hash.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation("Measure/#{measure_id}/$package", body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_url, 'url', resource)
        assert(!measure.nil?, "No Measure found in bundle with url: #{measure_url}")
        assert(measure.id == measure_id,
               "No Measure found in bundle with id: #{measure_id}")
        assert(resource_has_matching_identifier?(measure, measure_identifier),
               "No Measure found in bundle with identifier: #{measure_identifier}")
        unless measure_version.nil?
          assert(measure.version == measure_version,
                 "No Measure found in bundle with version: #{measure_version}")
        end
      end
    end
    # rubocop:enable Metrics/BlockLength

    test do
      title 'All related artifacts present'
      id 'measure-package-05'
      description 'returned bundle includes all related artifacts for all libraries'
      input :measure_id, title: 'Measure id'
      uses_request :measure_package
      run do
        assert(related_artifacts_present?(resource, false))
      end
    end

    test do
      title 'Throws 404 when no Measure on server matches id'
      id 'measure-package-06'
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
      id 'measure-package-07'
      description 'returns 400 status code with OperationOutcome when no id, url, or identifier provided'

      run do
        fhir_operation('Measure/$package')
        assert_response_status(400)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end

    test do
      optional
      title 'All related artifacts present including valuesets when include-terminology=true'
      id 'measure-package-08'
      description 'returned bundle includes all related artifacts for all libraries
      including valuesets with include-terminology=true'
      input :measure_id, title: 'Measure id'

      run do
        fhir_operation("Measure/#{measure_id}/$package?include-terminology=true")
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        measure = retrieve_measure_from_bundle(measure_id, 'id', resource)
        assert(!measure.nil?, "No Measure found in bundle with id: #{measure_id}")
        assert(related_artifacts_present?(resource, true))
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
