# frozen_string_literal: true

require_relative '../utils/spec_utils'

RSpec.describe MeasureRepositoryServiceTestKit::LibraryDataRequirements do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('measure_repository_service_test_suite') }
  let(:group) { suite.groups[6] }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: suite.id) }
  let(:url) { 'http://example.com/fhir' }
  let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }
  let(:dr_library) { FHIR::Library.new({ type: { coding: [{ code: 'module-definition' }] }, dataRequirement: [] }) }

  describe 'Server successfully returns a $data-requirements Library with id in url' do
    let(:test) { group.tests.first }
    let(:library_id) { 'library_id' }

    it 'passes if a 200 is returned with module-definition library body' do
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 200, body: dr_library.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 400, body: dr_library.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Library' do
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 200, body: FHIR::Bundle.new(id: 'bundle_id').to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Library in returned bundle is not of type module-definition' do
      other_library = dr_library.clone
      other_library.type.coding[0].code = 'logic-library'
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 200, body: other_library.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns a $data-requirements Library with url in body' do
    let(:test) { group.tests[1] }
    let(:library_url) { 'library_url' }
    let(:library_version) { 'library_version' }

    it 'passes if a 200 is returned with module-definition library body, given url and version' do
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 200, body: dr_library.to_json)

      result = run(test, url:, library_url:, library_version:)
      expect(result.result).to eq('pass')
    end

    it 'passes if a 200 is returned with module-definition library body, given just url' do
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 200, body: dr_library.to_json)

      result = run(test, url:, library_url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 400, body: dr_library.to_json)

      result = run(test, url:, library_url:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Library' do
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 200, body: FHIR::Bundle.new(id: 'bundle_id').to_json)

      result = run(test, url:, library_url:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Library in returned bundle is not of type module-definition' do
      other_library = dr_library.clone
      other_library.type.coding[0].code = 'logic-library'
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 200, body: other_library.to_json)

      result = run(test, url:, library_url:, library_version:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns bundle on Library $package with identifier in body' do
    let(:test) { group.tests[2] }
    let(:library_identifier) { 'identifier_system|identifier_value' }

    it 'passes if a 200 is returned with module-definition library body' do
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 200, body: dr_library.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 400, body: dr_library.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Library' do
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 200, body: FHIR::Bundle.new(id: 'bundle_id').to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Library in returned bundle is not of type module-definition' do
      other_library = dr_library.clone
      other_library.type.coding[0].code = 'logic-library'
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 200, body: other_library.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns bundle on Library $package with url, identifier, and version in body' do
    let(:test) { group.tests[3] }
    let(:library_id) { 'library_id' }
    let(:library_identifier) { 'identifier_system|identifier_value' }
    let(:library_url) { 'library_url' }
    let(:library_version) { 'library_version' }

    it 'passes if a 200 is returned with module-definition library body' do
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 200, body: dr_library.to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a 200 is not returned' do
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 400, body: dr_library.to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if body is not a Library' do
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 200, body: FHIR::Bundle.new(id: 'bundle_id').to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if Library in returned bundle is not of type module-definition' do
      other_library = dr_library.clone
      other_library.type.coding[0].code = 'logic-library'
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 200, body: other_library.to_json)

      result = run(test, url:, library_id:, library_url:, library_identifier:, library_version:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server returns 404 when no library matches id' do
    let(:test) { group.tests[4] }

    it 'passses when 404 returned with OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Library/INVALID_ID/$data-requirements"
      ).to_return(status: 404, body: error_outcome.to_json)

      result = run(test, url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if 200 status code returned' do
      stub_request(
        :post,
        "#{url}/Library/INVALID_ID/$data-requirements"
      ).to_return(status: 200, body: error_outcome.to_json)

      result = run(test, url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if library returned' do
      library = FHIR::Library.new
      stub_request(
        :post,
        "#{url}/Library/INVALID_ID/$data-requirements"
      ).to_return(status: 200, body: library.to_json)

      result = run(test, url:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server returns 400 when no id, url, or identifier provided' do
    let(:test) { group.tests[5] }

    it 'passes when 400 returned with OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 400, body: error_outcome.to_json)

      result = run(test, url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if 200 status code returned' do
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 200, body: error_outcome.to_json)

      result = run(test, url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if library body returned' do
      library = FHIR::Library.new
      stub_request(
        :post,
        "#{url}/Library/$data-requirements"
      ).to_return(status: 400, body: library.to_json)

      result = run(test, url:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server returns 400 when id is included in both the path and as a FHIR parameter' do
    let(:test) { group.tests[6] }
    let(:library_id) { 'library_id' }

    it 'passes when 400 returned with OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 400, body: error_outcome.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if 200 status code returned' do
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 200, body: error_outcome.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if library body returned' do
      library = FHIR::Library.new
      stub_request(
        :post,
        "#{url}/Library/#{library_id}/$data-requirements"
      ).to_return(status: 400, body: library.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end
  end
end
