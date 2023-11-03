# frozen_string_literal: true

require 'json'
require_relative '../utils/package_utils'
require_relative '../utils/general_utils'

module MeasureRepositoryServiceTestKit
  # tests for Library $cqfm.package service
  # rubocop:disable Metrics/ClassLength
  class LibraryPackage < Inferno::TestGroup
    include PackageUtils
    include GeneralUtils

    title 'Library $cqfm.package'
    description 'Ensure measure repository service can execute the $cqfm.package operation to the Library endpoint'
    id 'library_package'
    custom_headers = { 'content-type': 'application/fhir+json' }

    fhir_client do
      url :url
      headers custom_headers
    end

    test do
      title '200 response and JSON Bundle body for POST by id in url'
      id 'library-package-01'
      description 'returned response has status code 200 and valid JSON FHIR Bundle in body'
      input :library_id, title: 'Library id'
      makes_request :library_package
      run do
        fhir_operation("Library/#{library_id}/$cqfm.package", name: :library_package)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        library = retrieve_root_library_from_bundle(library_id, 'id', resource)
        assert(!library.nil?, "No Library found in bundle with id: #{library_id}")
      end
    end

    test do
      title '200 response and JSON Bundle body for POST with url in body'
      id 'library-package-02'
      description 'returned resopnse has status code 200 and included Library matches url parameter.'
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

        fhir_operation('Library/$cqfm.package', body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        library = retrieve_root_library_from_bundle(library_url, 'url', resource)
        assert(!library.nil?, "No Library found in bundle with url: #{library_url}")
      end
    end

    test do
      title '200 response and JSON Bundle body for POST with identifier in body'
      id 'library-package-03'
      description 'returned response has status code 200 and included Library matches identifier parameter.'
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

        fhir_operation('Library/$cqfm.package', body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        library = retrieve_root_library_from_bundle(library_identifier, 'identifier', resource)
        assert(!library.nil?, "No Library found in bundle with identifier: #{library_identifier}")
      end
    end

    # rubocop:disable Metrics/BlockLength
    test do
      title '200 response and JSON Bundle body for POST parameters url, identifier, and version in body and id in url'
      id 'library-package-04'
      description 'returned repsonse has status code 200 and included Library matches parameters url,
      identifier, and version. Verifies the server supports SHALL parameters for the operation'
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

        params_hash.freeze

        params = FHIR::Parameters.new params_hash

        fhir_operation("Library/#{library_id}/$cqfm.package", body: params)
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        library = retrieve_root_library_from_bundle(library_url, 'url', resource)
        assert(!library.nil?, "No Library found in bundle with url: #{library_url}")
        assert(library.id == library_id, "No Library found in bundle with id: #{library_id}")
        assert(resource_has_matching_identifier?(library, library_identifier),
               "No Library found in bundle with identifier: #{library_identifier}")
        unless library_version.nil?
          assert(library.version == library_version, "No Library found in bundle with version: #{library_version}")
        end
      end
    end
    # rubocop:enable Metrics/BlockLength

    test do
      title 'All related artifacts present'
      id 'library-package-05'
      description 'returned bundle includes all related artifacts for all libraries'
      input :library_id, title: 'Library id'
      uses_request :library_package

      run do
        assert(related_artifacts_present?(resource, false))
      end
    end

    test do
      title 'Throws 404 when no Library on server matches id'
      id 'library-package-06'
      description 'returns 404 status code with OperationOutcome when no Library exists with passed-in id'

      run do
        fhir_operation('Library/INVALID_ID/$cqfm.package')
        assert_response_status(404)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end

    test do
      title 'Throws 400 when no id, url, or identifier provided'
      id 'library-package-07'
      description 'returns 400 status code with OperationOutcome when no id, url, or identifier provided'

      run do
        fhir_operation('Library/$cqfm.package')
        assert_response_status(400)
        assert_valid_json(response[:body])
        assert(resource.resourceType == 'OperationOutcome')
        assert(resource.issue[0].severity == 'error')
      end
    end

    test do
      optional
      title 'All related artifacts present including valuesets when include-terminology=true'
      id 'library-package-08'
      description 'returned bundle includes all related artifacts for all libraries
      including valuesets with include-terminology=true'
      input :library_id, title: 'Library id'

      run do
        fhir_operation("Library/#{library_id}/$cqfm.package?include-terminology=true")
        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        library = retrieve_root_library_from_bundle(library_id, 'id', resource)
        assert(!library.nil?, "No Library found in bundle with id: #{library_id}")
        assert(related_artifacts_present?(resource, true))
      end
    end
  end
  # rubocop:enable Metrics/ClassLength
end
