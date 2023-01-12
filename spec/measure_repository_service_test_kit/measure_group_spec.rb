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
    let(:test) { group.tests.last }
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
end
