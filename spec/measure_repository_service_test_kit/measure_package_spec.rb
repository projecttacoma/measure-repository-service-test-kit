# frozen_string_literal: true

require_relative '../utils/spec_utils'

RSpec.describe MeasureRepositoryServiceTestKit::MeasurePackage do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('measure_repository_service_test_suite') }
  let(:group) { suite.groups[3] }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: suite.id) }
  let(:url) { 'http://example.com/fhir' }
  let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

  describe 'Server successfully returns bundle on Measure $package with id in url' do
    let(:test) { group.tests.first }
    let(:measure_id) { 'measure_id' }

    it 'passes if a 200 is returned with bundle body and id matches' do
      measure = FHIR::Measure.new(id: measure_id)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      measure = FHIR::Measure.new(id: measure_id)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Bundle' do
      measure = FHIR::Measure.new(id: measure_id)
      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 400, body: measure.to_json)

      result = run(test, url:, measure_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Measure in returned bundle does not match id' do
      measure = FHIR::Measure.new(id: 'invalid')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_id:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns bundle on Measure $package with url in body' do
    let(:test) { group.tests[1] }
    let(:measure_url) { 'measure_url' }

    it 'passes if a 200 is returned with bundle body and url matches' do
      measure = FHIR::Measure.new(url: measure_url)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, measure_url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      measure = FHIR::Measure.new(url: measure_url)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Bundle' do
      measure = FHIR::Measure.new(url: measure_url)
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 400, body: measure.to_json)

      result = run(test, url:, measure_url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Measure in returned bundle does not match url' do
      measure = FHIR::Measure.new(url: 'http://example.com/invalid')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_url:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns bundle on Measure $package with identifier in body' do
    let(:test) { group.tests[2] }
    let(:measure_identifier) { 'identifier_system|identifier_value' }
    let(:expected_identifier) { { system: 'identifier_system', value: 'identifier_value' } }

    it 'passes if a 200 is returned with bundle body and identifier matches' do
      measure = FHIR::Measure.new(identifier: expected_identifier)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      measure = FHIR::Measure.new(identifier: expected_identifier)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Bundle' do
      measure = FHIR::Measure.new(identifier: expected_identifier)
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 400, body: measure.to_json)

      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Measure in returned bundle does not match identifier system' do
      measure = FHIR::Measure.new(identifier: { system: 'invalid_system', value: 'identifier_value' })
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Measure in returned bundle does not match identifier value' do
      measure = FHIR::Measure.new(identifier: { system: 'identifier_system', value: 'invalid_value' })
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])
      stub_request(
        :post,
        "#{url}/Measure/$package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, measure_identifier:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns bundle on Measure $package with url, identifier, and version in body' do
    let(:test) { group.tests[3] }
    let(:measure_id) { 'measure_id' }
    let(:measure_identifier) { 'identifier_system|identifier_value' }
    let(:measure_url) { 'measure_url' }
    let(:measure_version) { 'measure_version' }
    let(:expected_identifier) { { system: 'identifier_system', value: 'identifier_value' } }

    it 'passes if a 200 is returned with bundle body and all fields match' do
      measure = FHIR::Measure.new(id: measure_id, url: measure_url, identifier: expected_identifier,
                                  version: measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, measure_id:, measure_url:, measure_identifier:, measure_version:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is returned with bundle body but id does not match' do
      measure = FHIR::Measure.new(id: 'invalid_id', url: measure_url, identifier: expected_identifier,
                                  version: measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, measure_id:, measure_url:, measure_identifier:,
                         measure_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but url does not match' do
      measure = FHIR::Measure.new(id: measure_id, url: 'invalid_url', identifier: expected_identifier,
                                  version: measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, measure_id:, measure_url:, measure_identifier:,
                         measure_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but version does not match' do
      measure = FHIR::Measure.new(id: measure_id, url: measure_url, identifier: expected_identifier,
                                  version: 'invalid_version')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, measure_id:, measure_url:, measure_identifier:,
                         measure_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but identifier system does not match' do
      measure = FHIR::Measure.new(id: measure_id, url: measure_url, identifier: { system: 'invalid_system',
                                                                                  value: 'identifier_value' },
                                  version: measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, measure_id:, measure_url:, measure_identifier:,
                         measure_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but identifier value does not match' do
      measure = FHIR::Measure.new(id: measure_id, url: measure_url, identifier: { system: 'identifier_system',
                                                                                  value: 'invalid_value' },
                                  version: measure_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: measure }])

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, measure_id:, measure_url:, measure_identifier:,
                         measure_version:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns all referenced Library related artifacts' do
    let(:test) { group.tests[4] }
    let(:measure_id) { 'measure_id' }
    let(:measure) { FHIR::Measure.new(id: measure_id, library: ['test-Library']) }
    let(:library) do
      FHIR::Library.new(url: 'test-Library', relatedArtifact: [{ type: 'depends-on', resource: 'dep-Library' }])
    end
    let(:dep_library) { FHIR::Library.new(url: 'dep-Library') }

    it 'passes if all related artifacts are present' do
      bundle = FHIR::Bundle.new(total: 3,
                                entry: [{ resource: measure }, { resource: library },
                                        { resource: dep_library }])
      repo_create(
        :request,
        name: 'measure_package',
        url: "http://example.com/Measure/#{measure_id}/$package",
        test_session_id: test_session.id,
        status: 200,
        response_body: bundle.to_json
      )
      result = run(test, url:, measure_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if related artifacts are missing' do
      bundle = FHIR::Bundle.new(total: 2,
                                entry: [{ resource: measure }, { resource: library }])
      repo_create(
        :request,
        name: 'measure_package',
        url: "http://example.com/Measure/#{measure_id}/$package",
        test_session_id: test_session.id,
        status: 200,
        response_body: bundle.to_json
      )
      result = run(test, url:, measure_id:)
      expect(result.result).to eq('fail')
    end

    it 'skips if measure_package request has not been made' do
      result = run(test, url:, measure_id:)
      expect(result.result).to eq('skip')
    end
  end

  describe 'Server returns 404 when no measure matches id' do
    let(:test) { group.tests[5] }
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
    let(:test) { group.tests[6] }
    let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

    it 'passes when 400 returned with OperationOutcome' do
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
