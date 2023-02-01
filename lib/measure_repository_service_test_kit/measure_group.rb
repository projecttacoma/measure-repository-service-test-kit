# frozen_string_literal: true

require 'json'
require_relative '../utils/general_utils'

module MeasureRepositoryServiceTestKit
  # tests for read by ID and search for Measure service
  # rubocop:disable Metrics/ClassLength
  class MeasureGroup < Inferno::TestGroup
    include GeneralUtils

    title 'Measure Read by Id and Search'
    description 'Ensure measure repository service can retrieve Measure resources by the server-defined id and search'
    id 'measure_group'

    fhir_client do
      url :url
    end

    status_type_options = { list_options: [{ label: 'Active', value: 'active' },
                                           { label: 'Draft', value: 'draft' },
                                           { label: 'Retired', value: 'retired' },
                                           { label: 'Unknown', value: 'unknown' }] }
    status_type_args = { type: 'radio', optional: false, default: 'active', options: status_type_options,
                         title: 'Status' }

    INVALID_ID = 'INVALID_ID'

    test do
      title 'Server returns 200 response status and correct Measure resource from the read interaction'
      id 'read-and-search-measure-01'
      description %(This test verifies that the Measure resource can be read from the server.)
      input :measure_id, title: 'Measure id'
      output :measure_id

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
      id 'read-and-search-measure-02'
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

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the measure
      matching a url'
      id 'read-and-search-measure-03'
      description %(This test verifies that a Measure resource can be found through search by url from the server.)
      input :measure_url, title: 'Measure url'

      run do
        fhir_search(:measure, params: { url: measure_url })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by url returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.url == measure_url,
               "Requested resource with url #{measure_url}, received resource with
                url #{resource.entry[0].resource.url}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the measure
      matching a version'
      id 'read-and-search-measure-04'
      description %(This test verifies that a Measure resource can be found through search by version
      from the server.)
      input :measure_version, title: 'Measure version'

      run do
        fhir_search(:measure, params: { version: measure_version })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by version returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.version == measure_version, "Requested resource with version
         #{measure_version}, received resource with version #{resource.entry[0].resource.version}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the measure
      matching an identifier'
      id 'read-and-search-measure-05'
      description %(This test verifies that a Measure resource can be found through search by identifier.)
      input :measure_identifier, title: 'Measure Identifier'

      run do
        fhir_search(:measure, params: { identifier: measure_identifier })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by identifier returned an empty FHIR searchset bundle')
        assert resource_has_matching_identifier?(resource.entry[0].resource, measure_identifier),
               "Requested resource with identifier #{measure_identifier}, received resource with identifier
        #{resource.entry[0].resource.identifier}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct verisons of the measure
      matching a name'
      id 'read-and-search-measure-06'
      description %(This test verifies that a Measure resource can be found through search by name from the
      server.)
      input :measure_name, title: 'Measure name'

      run do
        fhir_search(:measure, params: { name: measure_name })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by name returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.name.downcase.include?(measure_name.downcase), "Requested resource
        with name #{measure_name}, received resource with name #{resource.entry[0].resource.name}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the measure
      matching a title'
      id 'read-and-search-measure-07'
      description %(This test verifies a Measure resource can be found through search by title from the server.)
      input :measure_title, title: 'Measure title'

      run do
        fhir_search(:measure, params: { title: measure_title })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by title returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.title.downcase.include?(measure_title.downcase), "Requested resource
        with title #{measure_title}, received resource with title #{resource.entry[0].resource.title}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the measure
      matching a status'
      id 'read-and-search-measure-08'
      description %(This test verifies a Measure resource can be found through search by status from the server.)
      input :measure_status, **status_type_args

      run do
        fhir_search(:measure, params: { status: measure_status })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by status returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.status == measure_status, "Requested resource with status
         #{measure_status}, received resource with status #{resource.entry[0].resource.status}"
      end
    end

    test do
      title 'Server returns 200 response status and bundle that contains all the correct versions of the measure
      matching a description'
      id 'read-and-search-measure-09'
      description %(This test verifies a Measure resource can be found through search by description.)
      input :measure_description, title: 'Measure description'

      run do
        fhir_search(:measure, params: { description: measure_description })

        assert_response_status(200)
        assert_resource_type(:bundle)
        assert_valid_json(response[:body])
        assert(!resource.entry[0].nil?, 'Search by description returned an empty FHIR searchset bundle')
        assert resource.entry[0].resource.description.downcase.include?(measure_description.downcase),
               "Requested resource with description #{measure_description}, received resource with description
        #{resource.entry[0].resource.description}"
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
