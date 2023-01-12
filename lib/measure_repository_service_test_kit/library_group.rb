# frozen_string_literal: true

require 'json'

module MeasureRepositoryServiceTestKit
  # tests for read by ID and search for Library service
  class LibraryGroup < Inferno::TestGroup
    title 'Measure Repository Service Library Group'
    description 'Ensure measure repository service can retrieve Library resources by the server-defined id and search'
    id 'library_group'

    fhir_client do
      url :url
    end

    INVALID_ID = 'INVALID_ID'

    test do
      title 'Server returns 200 response status and correct Library resource from the read interaction'
      id 'read-by-id-library-01'
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
      id 'read-by-id-library-02'
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
  end
end
