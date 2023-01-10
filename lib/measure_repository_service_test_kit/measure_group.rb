# frozen_string_literal: true

require 'json'

module MeasureRepositoryServiceTestKit
  # tests for read by ID and search for Measure service
  class MeasureRepositoryServiceMeasureGroup < Inferno::TestGroup
    title 'Measure Repository Service Measure Group'
    description 'Ensure measure repository service can retrieve Measure resources by the server-defined id and search'
    id 'measure_group'

    fhir_client do
      url :url
    end

    INVALID_ID = 'INVALID_ID'

    test do
      title 'Server returns 200 response status and correct Measure resource from the read interaction'
      id 'read-by-id-measure-01'
      description %(This test verifies that the Measure resource can be read from the server.)
      input :measure_id, title: 'Measure id'

      run do
        fhir_read(:measure, measure_id)

        assert_response_status(200)
        assert_resource_type(:measure)
        assert_valid_json(response[:body])
        assert resource.id == measure_id,
               "Requested resource with id #{measure_id}, received resource with id #{resource.id}"
      end
    end

    test do
      title 'Server returns 404 response status when the resource is not available on the server'
      id 'read-by-id-measure-02'
      description %(This test verifies that the server appropriately returns 404 response status
                  for a resource whose id cannot be found in the server's database.)

      run do
        fhir_read(:measure, INVALID_ID)

        assert_response_status(404)
        assert_valid_json(response[:body])
        assert_resource_type(:operation_outcome)
        assert(resource.issue[0].severity == 'error')
      end
    end
  end
end
