# frozen_string_literal: true

require_relative '../utils/package_utils'

module MeasureRepositoryServiceTestKit
  # tests for include-terminology functionality for Library $package service
  # rubocop:disable Metrics/ClassLength
  class LibraryIncludeTerminology < Inferno::TestGroup
    include PackageUtils

    title 'Library include terminology $package'
    description 'Ensure measure repository service can execute the $package
        operation to the Library endpoint with include-terminology=true query parameter'
    id 'library_include_terminology'

    fhir_client do
      url :url
    end

    test do
      optional
      title '200 response and JSON Bundle body including root library resource for POST by id in url'
      id 'library-include-terminology-01'
      description 'returned response has status code 200 and valid JSON FHIR Bundle
            including root Library resource and valueset resources in body and include-terminology=true'
      input :library_id, title: 'Library id'
      makes_request :library_package_include_terminology
      run do
        fhir_operation("Library/#{library_id}/$package?include-terminology=true",
                       name: :library_package_include_terminology)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        library = retrieve_root_library_from_bundle(library_id, 'id', resource)
        assert(!library.nil?, "No Library found in bundle with id: #{library_id}")
      end
    end

    test do
      optional
      title '200 response and JSON Bundle body for POST with url in body'
      id 'library-include-terminology-02'
      description 'returned response has status code 200 and included Library matches url parameter
            and include-terminology=true'
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

        fhir_operation('Library/$package?include-terminology=true', body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        library = retrieve_root_library_from_bundle(library_url, 'url', resource)
        assert(!library.nil?, "No Library found in bundle with url: #{library_url}")
      end
    end

    test do
      optional
      title '200 response and JSON Bundle body for POST with identifier in body'
      id 'library-include-terminology-03'
      description 'returned response has status code 200 and included Library matches identifier
            parameter and include-terminology=true'
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

        fhir_operation('Library/$package?include-terminology=true', body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        library = retrieve_root_library_from_bundle(library_identifier, 'identifier', resource)
        assert(!library.nil?, "No Library found in bundle with identifier: #{library_identifier}")
      end
    end

    # rubocop:disable Metrics/BlockLength
    test do
      optional
      title '200 response and JSON Bundle body for POST parameters url, identifier, and version in body and id in url'
      id 'library-include-terminology-04'
      description 'returned response has status code 200 and included Library matches parameters url,
            identifier, and version with include-terminology=true. Verifies the server supports SHALL parameters
            for the operation'
      input :library_id, title: 'Library id'
      input :library_url, title: 'Library url'
      input :library_identifier, title: 'Library identifier'
      input :library_version, optional: true, title: 'Library version'

      run do
        params_hash = {
          resourceType: 'Parameters',
          parameter: [
            { name: 'url',
              valueUrl: library_url },
            { name: 'identifier',
              valueString: library_identifier }
          ]
        }
        params_hash[:parameter].append({ name: 'version', valueString: library_version }) unless library_version.nil?

        params_hash.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation("Library/#{library_id}/$package?include-terminology=true", body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        library = retrieve_root_library_from_bundle(library_url, 'url', resource)
        assert(!library.nil?, "No Library found in bundle with url: #{library_url}")
        assert(library.id == library_id,
               "No Library found in bundle with id: #{library_id}")
        assert(resource_has_matching_identifier?(library, library_identifier),
               "No Library found in bundle with identifier: #{library_identifier}")
        unless library_version.nil?
          assert(library.version == library_version,
                 "No Library found in bundle with version: #{library_version}")
        end
      end
    end
    # rubocop:enable Metrics/BlockLength

    test do
      optional
      title 'All related artifacts present including valuesets'
      id 'library-include-terminology-05'
      description 'returned bundle includes all artifacts for all libraries
        including valuesets with include-terminology=true'
      input :library_id, title: 'Library id'
      uses_request :library_package_include_terminology
      run do
        assert(related_artifacts_present?(resource))
        assert(related_valuesets_present?(resource))
      end
    end

    test do
      optional
      title 'Throws 404 when no Library on server matches id'
      id 'library-include-terminology-06'
      description 'returns 404 status code with OperationOutcome when no Library exists with
        passed-in id and include-terminology=true'

      run do
        fhir_operation('Library/INVALID_ID/$package?include-terminology=true')
        assert_response_status(404)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end

    test do
      optional
      title 'Throws 400 when no id, url, or identifier provided'
      id 'library-include-terminology-07'
      description 'returns 400 status code with OperationOutcome when no id, url, or identifier
        provided and include-terminology=true'

      run do
        fhir_operation('Library/$package?include-terminology=true')
        assert_response_status(400)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
