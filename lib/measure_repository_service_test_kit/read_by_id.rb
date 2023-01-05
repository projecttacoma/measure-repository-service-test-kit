# frozen_string_literal: true

require 'json'

module DEQMTestKit
  # tests for read by ID for Library and Measure services
  class ReadById < Inferno::TestGroup
  
    title 'Read by id'
    description 'Ensure measure repository service can retrieve Measure and Library resources by the server-defined id'
    id 'read_by_id'

    fhir_client do
      url :url
    end

    resource_type_options = { list_options: [{label: 'Measure', value: 'Measure'}, {label: 'Library', value: 'Library'}]}
    resource_type_args = { type: 'radio', optional: false, default: 'Measure', options: resource_type_options,
                        title: 'Resource Type' }

    INVALID_ID = 'INVALID_ID'

    test do
      title 'Server returns 200 response status and correct Measure/Library resource from the read interaction'
      id 'read-by-id-01'
      description %(This test verifies that the Measure and Library resources can be read from the server.)
      input :resource_type, **resource_type_args
      input :resource_id, title: 'Resource id'

      run do
        fhir_read(resource_type, resource_id)

        assert_response_status(200)
        assert_resource_type(resource_type)
        assert_valid_resource
        assert resource.id == resource_id,
               "Requested resource with id #{resource_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Server returns 404 response status when the resource is not available on the server'
      id 'read-by-id-01'
      description %(This test verifies that the server appropriately returns 404 response status for a resource whose id cannot be found in the server's database.)
      input :resource_type, **resource_type_args

      run do
        fhir_read(resource_type, INVALID_ID)

        assert_response_status(404)
        assert_resource_type(:operation_outcome)
        assert_valid_resource
        assert(resource.issue[0].severity == 'error')
      end
    end
  end
end