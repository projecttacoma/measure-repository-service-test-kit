# frozen_string_literal: true

require 'json'
require_relative '../utils/general_utils'

module MeasureRepositoryServiceTestKit
  # tests for Library $package service
  # rubocop:disable Metrics/ClassLength
  class LibraryDataRequirements < Inferno::TestGroup
    include GeneralUtils

    title 'Library $data-requirements'
    description 'Ensure measure repository service can execute the $data-requirements operation to the Library endpoint'
    id 'library_data_requirements'

    fhir_client do
      url :url
    end

    test do
      title '200 response and JSON Library body for POST by id in url'
      id 'library-data-requirements-01'
      description 'returned response has status code 200 and valid JSON FHIR Library with data requirement in body'
      input :library_id, title: 'Library id'
      makes_request :library_data_requirements
      run do
        fhir_operation("Library/#{library_id}/$data-requirements", name: :library_data_requirements)
        assert_response_status(200)
        assert_resource_type(:library)
        assert_valid_json(response[:body])
        assert(resource.dataRequirement, "No data requirement created for library with id: #{library_id}")
        assert resource.type.coding[0].code == 'module-definition',
               'Resulting data requirements Library is not type module-definition'
      end
    end

    test do
      title '200 response and JSON Library body for POST with url in body'
      id 'library-data-requirements-02'
      description 'returned resopnse has status code 200.'
      input :library_url, title: 'Library url'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            { name: 'url',
              valueUrl: library_url }
          ]
        }.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation('Library/$data-requirements', body: params)
        assert_response_status(200)
        assert_resource_type(:library)
        assert_valid_json(response[:body])
        assert(resource.dataRequirement, "No data requirement created for library with url: #{library_url}")
        assert resource.type.coding[0].code == 'module-definition',
               'Resulting data requirements Library is not type module-definition'
      end
    end

    test do
      title '200 response and JSON Library body for POST with identifier in body'
      id 'library-data-requirements-03'
      description 'returned response has status code 200.'
      input :library_identifier, title: 'Library Identifier'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            { name: 'identifier',
              valueString: library_identifier }
          ]
        }.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation('Library/$data-requirements', body: params)
        assert_response_status(200)
        assert_resource_type(:library)
        assert_valid_json(response[:body])
        assert(resource.dataRequirement,
               "No data requirement created for library with identifier: #{library_identifier}")
        assert resource.type.coding[0].code == 'module-definition',
               'Resulting data requirements Library is not type module-definition'
      end
    end

    test do
      title '200 response and JSON Bundle body for POST parameters url, identifier, and version in body and id in url'
      id 'library-data-requirements-04'
      description 'returned repsonse has status code 200.'
      input :library_id, title: 'Library id'
      input :library_url, title: 'Library url'
      input :library_identifier, title: 'Library identifier'
      input :library_version, optional: true, title: 'Library version'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            { name: 'url', valueUrl: library_url },
            { name: 'identifier', valueString: library_identifier }
          ]
        }
        params_hash[:parameter].append({ name: 'version', valueString: library_version }) unless library_version.nil?
        params = FHIR::Parameters.new params_hash.freeze

        fhir_operation("Library/#{library_id}/$data-requirements", body: params)
        assert_response_status(200)
        assert_resource_type(:library)
        assert_valid_json(response[:body])
        assert(resource.dataRequirement, "No data requirement created for library with id: #{library_id}")
        assert resource.type.coding[0].code == 'module-definition',
               'Resulting data requirements Library is not type module-definition'
      end
    end

    test do
      title 'Throws 404 when no Library on server matches id'
      id 'library-data-requirements-05'
      description 'returns 404 status code with OperationOutcome when no Library exists with passed-in id'

      run do
        fhir_operation('Library/INVALID_ID/$data-requirements')
        assert_response_status(404)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end

    test do
      title 'Throws 400 when no id, url, or identifier provided'
      id 'library-data-requirements-06'
      description 'returns 400 status code with OperationOutcome when no id, url, or identifier provided'

      run do
        fhir_operation('Library/$data-requirements')
        assert_response_status(400)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end

    test do
      title 'Throws 400 when id is included in both the path and as a FHIR parameter'
      id 'library-data-requirements-07'
      description 'returns 400 status code with OperationOutcome when no id, url, or identifier provided'
      input :library_id, title: 'Library id'
      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            { name: 'id',
              valueUrl: library_id }
          ]
        }.freeze

        params = FHIR::Parameters.new params_hash
        fhir_operation("Library/#{library_id}/$data-requirements", body: params)
        assert_response_status(400)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
