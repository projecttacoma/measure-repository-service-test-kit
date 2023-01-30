# frozen_string_literal: true

require_relative '../utils/spec_utils'

RSpec.describe MeasureRepositoryServiceTestKit::MeasureGroup do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('measure_repository_service_test_suite') }
  let(:group) { suite.groups[1] }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: suite.id) }
  let(:url) { 'http://example.com/fhir' }
  let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

  describe 'Server successfully retrieves specified resource by its id' do
    let(:test) { group.tests.first }
    let(:measure_id) { 'measure_id' }

    it 'passes if a Measure resource with the specified id was received' do
      resource = FHIR::Measure.new(id: measure_id)
      stub_request(
        :get,
        "#{url}/Measure/#{measure_id}"
      ).to_return(status: 200, body: resource.to_json)

      result = run(test, url:, measure_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if read interaction does not return 200' do
      resource = FHIR::Measure.new(id: measure_id)
      stub_request(
        :get,
        "#{url}/Measure/#{measure_id}"
      ).to_return(status: 400, body: resource.to_json)
      result = run(test, url:, measure_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the id received does not match the one requested' do
      resource = FHIR::Measure.new(id: 'INVALID_ID')
      stub_request(
        :get,
        "#{url}/Measure/#{measure_id}"
      ).to_return(status: 200, body: resource.to_json)
      result = run(test, url:, measure_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the resource type received does not match the one requested' do
      resource = FHIR::Library.new(id: 'INVALID_ID')
      stub_request(
        :get,
        "#{url}/Measure/#{measure_id}"
      ).to_return(status: 200, body: resource.to_json)
      result = run(test, url:, measure_id:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server returns 404 for id that does not exist on server database' do
    let(:test) { group.tests[1] }
    let(:measure_id) { 'INVALID_ID' }

    it 'passes if request returns 404 with OperationOutcome' do
      stub_request(
        :get,
        "#{url}/Measure/#{measure_id}"
      ).to_return(status: 404, body: error_outcome.to_json)
      result = run(test, url:, measure_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if request returns 200' do
      stub_request(
        :get,
        "#{url}/Measure/#{measure_id}"
      ).to_return(status: 200, body: error_outcome.to_json)
      result = run(test, url:, measure_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if request returns a Measure resource' do
      resource = FHIR::Measure.new(id: measure_id)
      stub_request(
        :get,
        "#{url}/Measure/#{measure_id}"
      ).to_return(status: 404, body: resource.to_json)
      result = run(test, url:, measure_id:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves specified resource by its url' do
    let(:test) { group.tests[2] }
    let(:measure_url) { 'measure_url' }

    it 'passes if the measures in the returned FHIR searchset bundle match the requested url' do
      measure = FHIR::Measure.new(url: measure_url)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?url=#{measure_url}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      measure =  FHIR::Measure.new(url: measure_url)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?url=#{measure_url}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the measures in the returned FHIR searchset bundle do not match the
      requested url' do
      measure = FHIR::Measure.new(url: 'INVALID_URL')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?url=#{measure_url}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      measure =  FHIR::Measure.new(url: 'INVALID_URL')
      stub_request(
        :get,
        "#{url}/Measure?url=#{measure_url}"
      ).to_return(status: 200, body: measure.to_json)

      result = run(test, url:, measure_url:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves specified resource by its version' do
    let(:test) { group.tests[3] }
    let(:measure_version) { 'measure_version' }

    it 'passes if the measures in the returned FHIR searchset bundle match the requested version' do
      measure = FHIR::Measure.new(version: measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?version=#{measure_version}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_version:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      measure =  FHIR::Measure.new(version: measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?version=#{measure_version}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the measures in the returned FHIR searchset bundle do not match the
      requested version' do
      measure = FHIR::Measure.new(version: 'INVALID_VERSION')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?version=#{measure_version}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      measure =  FHIR::Measure.new(version: 'INVALID_VERSION')
      stub_request(
        :get,
        "#{url}/Measure?version=#{measure_version}"
      ).to_return(status: 200, body: measure.to_json)

      result = run(test, url:, measure_version:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves specified resource by its identifier' do
    let(:test) { group.tests[4] }
    let(:measure_identifier) { 'identifier_system|identifier_value' }
    let(:expected_identifier) { { system: 'identifier_system', value: 'identifier_value' } }

    it 'passes if the measures in the returned FHIR searchset bundle match the requested identifier' do
      measure = FHIR::Measure.new(identifier: expected_identifier)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?identifier=#{measure_identifier}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      measure =  FHIR::Measure.new(identifier: measure_identifier)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?identifier=#{measure_identifier}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the measures in the returned FHIR searchset bundle do not match the
      requested identifier system' do
      measure = FHIR::Measure.new(identifier: { system: 'invalid_system', value: 'identifier_value' })
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?identifier=#{measure_identifier}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the measures in the returned FHIR searchset bundle do not match the
      requested identifier value' do
      measure = FHIR::Measure.new(identifier: { system: 'identifier_system', value: 'invalid_value' })
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?identifier=#{measure_identifier}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      measure =  FHIR::Measure.new(identifier: 'INVALID_IDENTIFIER')
      stub_request(
        :get,
        "#{url}/Measure?identifier=#{measure_identifier}"
      ).to_return(status: 200, body: measure.to_json)

      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves specified resource by its name' do
    let(:test) { group.tests[5] }
    let(:measure_name) { 'measure_name' }

    it 'passes if the measures in the returned FHIR searchset bundle match the requested name' do
      measure = FHIR::Measure.new(name: measure_name)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?name=#{measure_name}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_name:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      measure =  FHIR::Measure.new(name: measure_name)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?name=#{measure_name}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_name:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the measures in the returned FHIR searchset bundle do not match the
      requested name' do
      measure = FHIR::Measure.new(name: 'INVALID_NAME')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?name=#{measure_name}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_name:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      measure =  FHIR::Measure.new(name: 'INVALID_NAME')
      stub_request(
        :get,
        "#{url}/Measure?name=#{measure_name}"
      ).to_return(status: 200, body: measure.to_json)

      result = run(test, url:, measure_name:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves specified resource by its title' do
    let(:test) { group.tests[6] }
    let(:measure_title) { 'measure_title' }

    it 'passes if the measures in the returned FHIR searchset bundle match the requested title' do
      measure = FHIR::Measure.new(title: measure_title)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?title=#{measure_title}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_title:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      measure =  FHIR::Measure.new(title: measure_title)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?title=#{measure_title}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_title:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the measures in the returned FHIR searchset bundle do not match the
      requested title' do
      measure = FHIR::Measure.new(title: 'INVALID_TITLE')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?title=#{measure_title}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_title:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      measure =  FHIR::Measure.new(title: 'INVALID_TITLE')
      stub_request(
        :get,
        "#{url}/Measure?title=#{measure_title}"
      ).to_return(status: 200, body: measure.to_json)

      result = run(test, url:, measure_title:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves specified resource by its status' do
    let(:test) { group.tests[7] }
    let(:measure_status) { 'measure_status' }

    it 'passes if the measures in the returned FHIR searchset bundle match the requested status' do
      measure = FHIR::Measure.new(status: measure_status)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?status=#{measure_status}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_status:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      measure =  FHIR::Measure.new(status: measure_status)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?status=#{measure_status}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_status:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the measures in the returned FHIR searchset bundle do not match the
      requested status' do
      measure = FHIR::Measure.new(status: 'INVALID_STATUS')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?status=#{measure_status}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_status:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      measure =  FHIR::Measure.new(status: 'INVALID_STATUS')
      stub_request(
        :get,
        "#{url}/Measure?status=#{measure_status}"
      ).to_return(status: 200, body: measure.to_json)

      result = run(test, url:, measure_status:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves specified resource by its description' do
    let(:test) { group.tests[8] }
    let(:measure_description) { 'measure_description' }

    it 'passes if the measures in the returned FHIR searchset bundle match the requested description' do
      measure = FHIR::Measure.new(description: measure_description)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?description=#{measure_description}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_description:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      measure =  FHIR::Measure.new(description: measure_description)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?description=#{measure_description}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_description:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the measures in the returned FHIR searchset bundle do not match the
      requested description' do
      measure = FHIR::Measure.new(description: 'INVALID_DESCRIPTION')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :get,
        "#{url}/Measure?description=#{measure_description}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_description:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      measure =  FHIR::Measure.new(description: 'INVALID_DESCRIPTION')
      stub_request(
        :get,
        "#{url}/Measure?description=#{measure_description}"
      ).to_return(status: 200, body: measure.to_json)

      result = run(test, url:, measure_description:)
      expect(result.result).to eq('fail')
    end
  end
end
