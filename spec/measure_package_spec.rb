# frozen_string_literal: true

RSpec.describe MeasureRepositoryServiceTestKit::MeasurePackage do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('measure_repository_service_test_suite') }
  let(:group) { suite.groups[1] }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: suite.id) }
  let(:url) { 'http://example.com/fhir' }
  let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

  def run(runnable, inputs = {})
    test_run_params = { test_session_id: test_session.id }.merge(runnable.reference_hash)
    test_run = Inferno::Repositories::TestRuns.new.create(test_run_params)
    inputs.each do |name, value|
      session_data_repo.save(test_session_id: test_session.id, name:, value:, type: 'text')
    end
    Inferno::TestRunner.new(test_session:, test_run:).run(runnable)
  end

  describe 'Server successfully returns bundle on Measure $package with id in url' do
    let(:test) { group.tests.first }
    let(:selected_measure_id) { 'measure_id' }

    it 'passes if a 200 is returned with bundle body and id matches' do
      measure = FHIR::Measure.new(id: selected_measure_id)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/#{selected_measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, selected_measure_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      measure = FHIR::Measure.new(id: selected_measure_id)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/#{selected_measure_id}/$package"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, selected_measure_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Bundle' do
      measure = FHIR::Measure.new(id: selected_measure_id)
      stub_request(
        :post,
        "#{url}/Measure/#{selected_measure_id}/$package"
      ).to_return(status: 400, body: measure.to_json)

      result = run(test, url:, selected_measure_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Measure in returned bundle does not match id' do
      measure = FHIR::Measure.new(id: 'invalid')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/#{selected_measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, selected_measure_id:)
      expect(result.result).to eq('fail')
    end
  end
  describe 'Server successfully returns bundle on Measure $package with url, identifier, and version in body' do
    let(:test) { group.tests[1] }
    let(:selected_measure_id) { 'measure_id' }
    let(:selected_measure_identifier) { 'identifier_system|identifier_value' }
    let(:selected_measure_url) { 'measure_url' }
    let(:selected_measure_version) { 'measure_version' }
    let(:expected_identifier) { { system: 'identifier_system', value: 'identifier_value' } }

    it 'passes if a 200 is returned with bundle body and all fields match' do
      measure = FHIR::Measure.new(url: selected_measure_url, identifier: expected_identifier,
                                  version: selected_measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, selected_measure_url:, selected_measure_identifier:, selected_measure_version:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is returned with bundle body but url does not match' do
      measure = FHIR::Measure.new(url: selected_measure_url, identifier: expected_identifier,
                                  version: selected_measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, selected_measure_url: 'invalid_url', selected_measure_identifier:,
                         selected_measure_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but version does not match' do
      measure = FHIR::Measure.new(url: selected_measure_url, identifier: expected_identifier,
                                  version: selected_measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, selected_measure_url:, selected_measure_identifier:,
                         selected_measure_version: 'invalid_version')
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but identifier system does not match' do
      measure = FHIR::Measure.new(url: selected_measure_url, identifier: expected_identifier,
                                  version: selected_measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, selected_measure_url:, selected_measure_identifier: 'invalid_system|identifier_value',
                         selected_measure_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but identifier value does not match' do
      measure = FHIR::Measure.new(url: selected_measure_url, identifier: expected_identifier,
                                  version: selected_measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, selected_measure_url:, selected_measure_identifier: 'identifier_system|invalid_value',
                         selected_measure_version:)
      expect(result.result).to eq('fail')
    end
  end

  #   describe 'Server successfully returns all referenced Library related artifacts' do
  #     let(:test) { group.tests[2] }
  #     let(:selected_measure_id) { 'measure_id' }
  #     let(:measure) { FHIR::Measure.new(id: selected_measure_id, library: ['test-Library']) }
  #     let(:library) do
  #       FHIR::Library.new(url: 'test-Library', relatedArtifact: [{ type: 'depends-on', resource: 'dep-Library' }])
  #     end
  #     let(:dep_library) { FHIR::Library.new(url: 'dep-Library') }
  #     it 'passes if all related artifacts are present' do
  #       bundle = FHIR::Bundle.new(total: 3,
  #                                 entry: [{ resource: measure }, { resource: library },
  #                                         { resource: dep_library }])
  #       stub_request(
  #         :post,
  #         "#{url}/Measure/#{selected_measure_id}/$package"
  #       ).to_return(status: 200, body: bundle.to_json)
  #       result = run(test, url:, selected_measure_id:, uses_request:)
  #       expect(result.result).to eq('pass')
  #     end
  #   end
  describe 'Server returns 404 when no measure matches id' do
    let(:test) { group.tests[3] }
    let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

    it 'passes when 404 returned with OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Measure/INVALID_ID/$package"
      ).to_return(status: 404, body: error_outcome.to_json)
      result = run(test, url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if 200 status code returned' do
      stub_request(
        :post,
        "#{url}/Measure/INVALID_ID/$package"
      ).to_return(status: 200, body: error_outcome.to_json)
      result = run(test, url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if bundle returned' do
      bundle = FHIR::Bundle.new
      stub_request(
        :post,
        "#{url}/Measure/INVALID_ID/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server returns 400 when no id, url, or identifier provided' do
    let(:test) { group.tests[4] }
    let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

    it 'passes when 404 returned with OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 400, body: error_outcome.to_json)
      result = run(test, url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if 200 status code returned' do
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: error_outcome.to_json)
      result = run(test, url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if bundle status code returned' do
      bundle = FHIR::Bundle.new
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 400, body: bundle.to_json)
      result = run(test, url:)
      expect(result.result).to eq('fail')
    end
  end
end
