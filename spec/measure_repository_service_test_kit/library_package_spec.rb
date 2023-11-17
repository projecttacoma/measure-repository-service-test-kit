# frozen_string_literal: true

require_relative '../utils/spec_utils'

RSpec.describe MeasureRepositoryServiceTestKit::LibraryPackage do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('measure_repository_service_test_suite') }
  let(:group) { suite.groups[4] }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: suite.id) }
  let(:url) { 'http://example.com/fhir' }
  let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

  describe 'Server successfully returns bundle on Library $cqfm.package with id in url' do
    let(:test) { group.tests.first }
    let(:library_id) { 'library_id' }

    it 'passes if a 200 is returned with bundle body and id matches' do
      library = FHIR::Library.new(id: library_id)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      library = FHIR::Library.new(id: library_id)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Bundle' do
      library = FHIR::Library.new(id: library_id)
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 400, body: library.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Library in returned bundle does not match id' do
      library = FHIR::Library.new(id: 'invalid')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns bundle on Measure $cqfm.package with url in body' do
    let(:test) { group.tests[1] }
    let(:library_url) { 'library_url' }

    it 'passes if a 200 is returned with bundle body and url matches' do
      library = FHIR::Library.new(url: library_url)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])

      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)
      result = run(test, url:, library_url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      library = FHIR::Library.new(url: library_url)
      bundle = FHIR::Library.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Bundle' do
      library = FHIR::Library.new(url: library_url)
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 400, body: library.to_json)

      result = run(test, url:, library_url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Library in returned Bundle does not match url' do
      library = FHIR::Library.new(url: 'http://example.com/invalid')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_url:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns bundle on Library $cqfm.package with identifier in body' do
    let(:test) { group.tests[2] }
    let(:library_identifier) { 'identifier_system|identifier_value' }
    let(:expected_identifier) { { system: 'identifier_system', value: 'identifier_value' } }

    it 'passes if a 200 is returned with bundle body and identifier matches' do
      library = FHIR::Library.new(identifier: expected_identifier)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      library = FHIR::Library.new(identifier: expected_identifier)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Bundle' do
      library = FHIR::Library.new(identifier: expected_identifier)
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 400, body: library.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Library in returned bundle does not match identifier system' do
      library = FHIR::Library.new(identifier: { system: 'invalid_system', value: 'identifier_value' })
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Library in reutrned bundle does not match identifier value' do
      library = FHIR::Library.new(identifier: { system: 'identifier_system', value: 'invalid_value' })
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns bundle on Library $cqfm.package with url, identifier, and version in body' do
    let(:test) { group.tests[3] }
    let(:library_id) { 'library_id' }
    let(:library_identifier) { 'identifier_system|identifier_value' }
    let(:library_url) { 'library_url' }
    let(:library_version) { 'library_version' }
    let(:expected_identifier) { { system: 'identifier_system', value: 'identifier_value' } }

    it 'passes if a 200 is returned with bundle body and all fields match' do
      library = FHIR::Library.new(id: library_id, url: library_url, identifier: expected_identifier,
                                  version: library_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is returned with bundle body but id does not match' do
      library = FHIR::Library.new(id: 'invalid_id', url: library_url, identifier: expected_identifier,
                                  version: library_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but url does not match' do
      library = FHIR::Library.new(id: library_id, url: 'invalid_url', identifier: expected_identifier,
                                  version: library_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but version does not match' do
      library = FHIR::Library.new(id: library_id, url: library_url, identifier: expected_identifier,
                                  version: 'invalid_version')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but identifier system does not match' do
      library = FHIR::Library.new(id: library_id, url: library_url,
                                  identifier: { system: 'invalid_system', value: 'identifier_value' },
                                  version: library_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if a 200 is returned with bundle body but identifier value does not match' do
      library = FHIR::Library.new(id: library_id, url: library_url,
                                  identifier: { system: 'identifier_system', value: 'invalid_value' },
                                  version: library_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns all referenced Library related artifacts' do
    let(:test) { group.tests[4] }
    let(:library_id) { 'library_id' }
    let(:library) do
      FHIR::Library.new(url: 'test-Library', relatedArtifact: [{ type: 'depends-on', resource: 'dep-Library' }])
    end
    let(:dep_library) { FHIR::Library.new(url: 'dep-Library') }

    it 'passes if all related artifacts are present' do
      bundle = FHIR::Bundle.new(total: 2, entry: [{ resource: library }, { resource: dep_library }])
      repo_create(
        :request,
        name: 'library_package',
        url: "http://example.com/Library/#{library_id}/$cqfm.package",
        test_session_id: test_session.id,
        status: 200,
        response_body: bundle.to_json
      )

      result = run(test, url:, library_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if related artifacts are missing' do
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      repo_create(
        :request,
        name: 'library_package',
        url: "http://example.com/Library/#{library_id}/$cqfm.package",
        test_session_id: test_session.id,
        status: 200,
        response_body: bundle.to_json
      )

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'skips if library_package request has not been made' do
      result = run(test, url:, library_id:)
      expect(result.result).to eq('skip')
    end
  end

  describe 'Server returns 404 when no library matches id' do
    let(:test) { group.tests[5] }
    let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

    it 'passses when 404 returned with OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Library/INVALID_ID/$cqfm.package"
      ).to_return(status: 404, body: error_outcome.to_json)

      result = run(test, url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if 200 status code returned' do
      stub_request(
        :post,
        "#{url}/Library/INVALID_ID/$cqfm.package"
      ).to_return(status: 200, body: error_outcome.to_json)

      result = run(test, url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if bundle returned' do
      bundle = FHIR::Bundle.new
      stub_request(
        :post,
        "#{url}/Library/INVALID_ID/$cqfm.package"
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
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 400, body: error_outcome.to_json)
      result = run(test, url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if 200 status code returned' do
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 200, body: error_outcome.to_json)
      result = run(test, url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if bundle body returned' do
      bundle = FHIR::Bundle.new
      stub_request(
        :post,
        "#{url}/Library/$cqfm.package"
      ).to_return(status: 400, body: bundle.to_json)
      result = run(test, url:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns all referenced Library related artifacts including valuesets
  with include-terminology=true' do
    let(:test) { group.tests[7] }
    let(:library_id) { 'library_id' }
    let(:library) do
      FHIR::Library.new(id: library_id, url: 'test-Library',
                        relatedArtifact: [{ type: 'depends-on', resource: 'dep-Library' },
                                          { type: 'depends-on',
                                            resource: 'dep-ValueSet' }])
    end
    let(:dep_library) { FHIR::Library.new(url: 'dep-Library') }
    let(:dep_valueset) { FHIR::ValueSet.new(url: 'dep-ValueSet') }

    it 'passes if all related artifacts are present' do
      bundle = FHIR::Bundle.new(total: 3,
                                entry: [{ resource: library },
                                        { resource: dep_library }, { resource: dep_valueset }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package?include-terminology=true"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if valueset related artifacts are missing' do
      bundle = FHIR::Bundle.new(total: 2,
                                entry: [{ resource: library },
                                        { resource: dep_library }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package?include-terminology=true"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if library related artifacts are missing' do
      bundle = FHIR::Bundle.new(total: 2,
                                entry: [{ resource: library }, { resource: dep_valueset }])
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$cqfm.package?include-terminology=true"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end
  end
end
