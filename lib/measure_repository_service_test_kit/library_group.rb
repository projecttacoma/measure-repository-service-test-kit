# frozen_string_literal: true

require 'json'
require_relative '../utils/package_utils'

module MeasureRepositoryServiceTestKit
  # tests for read by ID and search for Library service
  # rubocop:disable Metrics/ClassLength
  class LibraryGroup < Inferno::TestGroup
    include PackageUtils

    title 'Library Read by Id and Search'
    description 'Ensure measure repository service can retrieve Library resources by the server-defined id and search'
    id 'library_group'

    fhir_client do
      url :url
    end

    INVALID_ID = 'INVALID_ID'

    test do
      title 'Server returns 200 response status and correct Library resource from the read interaction'
      id 'read-and-search-library-01'
      description %(This test verifies that the Library resource can be read from the server.)
      input :library_id, title: 'Library id'

      run do
        fhir_read(:library, library_id)

        assert_response_status(200)
        assert_resource_type(:library)
        assert_valid_json(response[:body])
        assert resource.id == library_id,
               "Requested resource with id #{library_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Server returns 404 response status when the resource is not available on the server'
      id 'read-and-search-library-02'
      description %(This test verifies that the server appropriately returns 404 response status
                  for a resource whose id cannot be found in the server's database.)

      run do
        fhir_read(:library, INVALID_ID)

        assert_response_status(404)
        assert_resource_type(:operation_outcome)
        assert_valid_json(response[:body])
        assert(resource.issue[0].severity == 'error')
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the library
      matching a url'
      id 'read-and-search-library-03'
      description %(This test verifies that a Library resource can be found through search by url from the server.)
      input :library_url, title: 'Library url'

      run do
        fhir_search(:library, params: { url: library_url })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by url returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.url == library_url,
               "Requested resource with url #{library_url}, received resource with
               url #{resource.entry[0].resource.url}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the library
      matching a version'
      id 'read-and-search-library-04'
      description %(This test verifies that a Library resource can be found through search by version from
      the server.)
      input :library_version, title: 'Library version'

      run do
        fhir_search(:library, params: { version: library_version })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by version returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.version == library_version, "Requested resource with
        version #{library_version}, received resource with version #{resource.entry[0].resource.version}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the library
      matching an identifier'
      id 'read-and-search-library-05'
      description %(This test verifies that a Library resource can be found through search by identifier from
      the server.)
      input :library_identifier, title: 'Library Identifier'

      run do
        fhir_search(:library, params: { identifier: library_identifier })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by identifier returned an empty FHIR searchset bundle')
        assert resource_has_matching_identifier?(resource.entry[0].resource, library_identifier),
               "Requested resource with identifier #{library_identifier}, received resource with identifier
        #{resource.entry[0].resource.identifier}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the library
      matching a name'
      id 'read-and-search-library-06'
      description %(This test verifies that a Library resource can be found through search by name from the server.)
      input :library_name, title: 'Library name'

      run do
        fhir_search(:library, params: { name: library_name })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by name returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.name.downcase.include?(library_name.downcase), "Requested resource
        with name #{library_name}, received resource with name #{resource.entry[0].resource.name}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the library
      matching a title'
      id 'read-and-search-library-07'
      description %(This test verifies a Library resource can be found through search by title from the server.)
      input :library_title, title: 'Library title'

      run do
        fhir_search(:library, params: { title: library_title })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by title returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.title.downcase.include?(library_title.downcase), "Requested resource
        with title #{library_title}, received resource with title #{resource.entry[0].resource.title}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the library
      matching a status'
      id 'read-and-search-library-08'
      description %(This test verifies a Library resource can be found through search by status from the server.)
      input :library_status, title: 'Library status'

      run do
        fhir_search(:library, params: { status: library_status })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by status returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.status == library_status, "Requested resource with status
         #{library_status}, received resource with status #{resource.entry[0].resource.status}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the library
      matching a description'
      id 'read-and-search-library-09'
      description %(This test verifies a Library resource can be found through search by description from the
      server.)
      input :library_description, title: 'Library description'

      run do
        fhir_search(:library, params: { description: library_description })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by description returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.description.downcase.include?(library_description.downcase),
               "Requested resource with description #{library_description}, received resource with description
        #{resource.entry[0].resource.description}"
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
