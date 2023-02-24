# frozen_string_literal: true

require 'json'
require_relative '../utils/data_requirements_utils'

module MeasureRepositoryServiceTestKit
  # tests for Library $package service
  # rubocop:disable Metrics/ClassLength
  class LibraryDataRequirements < Inferno::TestGroup
    title 'Library $data-requirements'
    description 'Ensure measure repository service can run Library/$data-requirements operation'
    id 'library_data_requirements'
    custom_headers = { 'content-type': 'application/fhir+json' }

    fhir_client do
      url :url
      headers custom_headers
    end

    test do
      include DataRequirementsUtils
      title '200 response and JSON Library body for POST by id in url'
      id 'library-data-requirements-01'
      description 'returned response has status code 200 and valid JSON FHIR Library with data requirement in body'
      input :library_id, title: 'Library id'
      makes_request :library_data_requirements

      run do
        fhir_operation("Library/#{library_id}/$data-requirements", name: :library_data_requirements)
        assert_dr_success
      end
    end

    test do
      include DataRequirementsUtils
      title '200 response and JSON Library body for POST with url in body'
      id 'library-data-requirements-02'
      description 'returned response has status code 200.'
      input :library_url, title: 'Library url'
      input :library_version, optional: true, title: 'Library version'

      run do
        url_params_hash = {
          resourceType: 'Parameters',
          parameter: [
            { name: 'url',
              valueUrl: library_url }
          ]
        }

        unless library_version.nil?
          url_params_hash[:parameter].append({ name: 'version',
                                               valueString: library_version })
        end

        url_params_hash = url_params_hash.freeze
        url_params = FHIR::Parameters.new url_params_hash

        fhir_operation('Library/$data-requirements', body: url_params)
        assert_dr_success
      end
    end

    test do
      include DataRequirementsUtils
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
        assert_dr_success
      end
    end

    test do
      include DataRequirementsUtils
      title '200 response and JSON Bundle body for POST parameters url, identifier, and version in body and id in url'
      id 'library-data-requirements-04'
      description 'returned response has status code 200.'
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
        assert_dr_success
      end
    end

    test do
      include DataRequirementsUtils
      title 'Throws 404 when no Library on server matches id'
      id 'library-data-requirements-05'
      description 'returns 404 status code with OperationOutcome when no Library exists with passed-in id'

      run do
        fhir_operation('Library/INVALID_ID/$data-requirements')
        assert_dr_failure(expected_status: 404)
      end
    end

    test do
      include DataRequirementsUtils
      title 'Throws 400 when no id, url, or identifier provided'
      id 'library-data-requirements-06'
      description 'returns 400 status code with OperationOutcome when no id, url, or identifier provided'

      run do
        fhir_operation('Library/$data-requirements')
        assert_dr_failure
      end
    end

    test do
      include DataRequirementsUtils
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
        assert_dr_failure
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
