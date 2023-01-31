# frozen_string_literal: true

require_relative '../utils/spec_utils'

RSpec.describe MeasureRepositoryServiceTestKit::LibraryGroup do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('measure_repository_service_test_suite') }
  let(:group) { suite.groups[2] }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: suite.id) }
  let(:url) { 'http://example.com/fhir' }
  let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }

  describe 'Server successfully retrieves Library by its id' do
    let(:test) { group.tests.first }
    let(:library_id) { 'library_id' }

    it 'passes if a Library resource with the specified id was received' do
      resource = FHIR::Library.new(id: library_id)
      stub_request(
        :get,
        "#{url}/Library/#{library_id}"
      ).to_return(status: 200, body: resource.to_json)

      result = run(test, url:, library_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if read interaction does not return 200' do
      resource = FHIR::Library.new(id: library_id)
      stub_request(
        :get,
        "#{url}/Library/#{library_id}"
      ).to_return(status: 400, body: resource.to_json)
      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the id received does not match the one requested' do
      resource = FHIR::Library.new(id: 'INVALID_ID')
      stub_request(
        :get,
        "#{url}/Library/#{library_id}"
      ).to_return(status: 200, body: resource.to_json)
      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the resource type received does not match the one requested' do
      resource = FHIR::Measure.new(id: 'INVALID_ID')
      stub_request(
        :get,
        "#{url}/Library/#{library_id}"
      ).to_return(status: 200, body: resource.to_json)
      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server returns 404 for id that does not exist on server database' do
    let(:test) { group.tests[1] }
    let(:library_id) { 'INVALID_ID' }

    it 'passes if request returns 404 with OperationOutcome' do
      stub_request(
        :get,
        "#{url}/Library/#{library_id}"
      ).to_return(status: 404, body: error_outcome.to_json)
      result = run(test, url:, library_id:)
      expect(result.result).to eq('pass')
    end

    it 'fails if request returns 200' do
      stub_request(
        :get,
        "#{url}/Library/#{library_id}"
      ).to_return(status: 200, body: error_outcome.to_json)
      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end

    it 'fails if request returns a Library resource' do
      resource = FHIR::Library.new(id: library_id)
      stub_request(
        :get,
        "#{url}/Library/#{library_id}"
      ).to_return(status: 404, body: resource.to_json)
      result = run(test, url:, library_id:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves Library by its url' do
    let(:test) { group.tests[2] }
    let(:library_url) { 'library_url' }

    it 'passes if the libraries in the returned FHIR searchset bundle match the requested url' do
      library = FHIR::Library.new(url: library_url)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?url=#{library_url}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_url:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      library =  FHIR::Library.new(url: library_url)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?url=#{library_url}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the libraries in the returned FHIR searchset bundle do not match the
      requested url' do
      library = FHIR::Library.new(url: 'INVALID_URL')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?url=#{library_url}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_url:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      library = FHIR::Library.new(url: library_url)
      stub_request(
        :get,
        "#{url}/Library?url=#{library_url}"
      ).to_return(status: 200, body: library.to_json)

      result = run(test, url:, library_url:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves Library by its version' do
    let(:test) { group.tests[3] }
    let(:library_version) { 'library_version' }

    it 'passes if the libraries in the returned FHIR searchset bundle match the requested version' do
      library = FHIR::Library.new(version: library_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?version=#{library_version}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_version:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      library =  FHIR::Library.new(version: library_version)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?version=#{library_version}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the libraries in the returned FHIR searchset bundle do not match the
      requested version' do
      library = FHIR::Library.new(version: 'INVALID_VERSION')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?version=#{library_version}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_version:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      library =  FHIR::Library.new(version: library_version)
      stub_request(
        :get,
        "#{url}/Library?version=#{library_version}"
      ).to_return(status: 200, body: library.to_json)

      result = run(test, url:, library_version:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves Library by its identifier' do
    let(:test) { group.tests[4] }
    let(:library_identifier) { 'identifier_system|identifier_value' }
    let(:expected_identifier) { { system: 'identifier_system', value: 'identifier_value' } }

    it 'passes if the libraries in the returned FHIR searchset bundle match the requested identifier' do
      library = FHIR::Library.new(identifier: expected_identifier)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?identifier=#{library_identifier}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      library =  FHIR::Library.new(identifier: library_identifier)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?identifier=#{library_identifier}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the libraries in the returned FHIR searchset bundle do not match the
      requested identifier system' do
      library = FHIR::Library.new(identifier: { system: 'invalid_system', value: 'identifier_value' })
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?identifier=#{library_identifier}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the libraries in the returned FHIR searchset bundle do not match the
      requested identifier value' do
      library = FHIR::Library.new(identifier: { system: 'identifier_system', value: 'invalid_value' })
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?identifier=#{library_identifier}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      library =  FHIR::Library.new(identifier: library_identifier)
      stub_request(
        :get,
        "#{url}/Library?identifier=#{library_identifier}"
      ).to_return(status: 200, body: library.to_json)

      result = run(test, url:, library_identifier:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves Library by its name' do
    let(:test) { group.tests[5] }
    let(:library_name) { 'library_name' }

    it 'passes if the libraries in the returned FHIR searchset bundle match the requested name' do
      library = FHIR::Library.new(name: library_name)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?name=#{library_name}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_name:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      library =  FHIR::Library.new(name: library_name)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?name=#{library_name}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_name:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the libraries in the returned FHIR searchset bundle do not match the
      requested name' do
      library = FHIR::Library.new(name: 'INVALID_NAME')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?name=#{library_name}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_name:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      library =  FHIR::Library.new(name: library_name)
      stub_request(
        :get,
        "#{url}/Library?name=#{library_name}"
      ).to_return(status: 200, body: library.to_json)

      result = run(test, url:, library_name:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves Library by its title' do
    let(:test) { group.tests[6] }
    let(:library_title) { 'library_title' }

    it 'passes if the libraries in the returned FHIR searchset bundle match the requested title' do
      library = FHIR::Library.new(title: library_title)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?title=#{library_title}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_title:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      library =  FHIR::Library.new(title: library_title)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?title=#{library_title}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_title:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the libraries in the returned FHIR searchset bundle do not match the
      requested title' do
      library = FHIR::Library.new(title: 'INVALID_TITLE')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?title=#{library_title}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_title:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      library =  FHIR::Library.new(title: library_title)
      stub_request(
        :get,
        "#{url}/Library?title=#{library_title}"
      ).to_return(status: 200, body: library.to_json)

      result = run(test, url:, library_title:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves Library by its status' do
    let(:test) { group.tests[7] }
    let(:library_status) { 'library_status' }

    it 'passes if the libraries in the returned FHIR searchset bundle match the requested status' do
      library = FHIR::Library.new(status: library_status)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?status=#{library_status}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_status:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      library =  FHIR::Library.new(status: library_status)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?status=#{library_status}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_status:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the libraries in the returned FHIR searchset bundle do not match the
      requested status' do
      library = FHIR::Library.new(status: 'active')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?status=#{library_status}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_status:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      library =  FHIR::Library.new(status: library_status)
      stub_request(
        :get,
        "#{url}/Library?status=#{library_status}"
      ).to_return(status: 200, body: library.to_json)

      result = run(test, url:, library_status:)
      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully searches and retrieves Library by its description' do
    let(:test) { group.tests[8] }
    let(:library_description) { 'library_description' }

    it 'passes if the libraries in the returned FHIR searchset bundle match the requested description' do
      library = FHIR::Library.new(description: library_description)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?description=#{library_description}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_description:)
      expect(result.result).to eq('pass')
    end

    it 'fails if search does not return 200' do
      library =  FHIR::Library.new(description: library_description)
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?description=#{library_description}"
      ).to_return(status: 400, body: bundle.to_json)

      result = run(test, url:, library_description:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the libraries in the returned FHIR searchset bundle do not match the
      requested description' do
      library = FHIR::Library.new(description: 'INVALID_DESCRIPTION')
      bundle = FHIR::Bundle.new(total: 1, entry: [{ resource: library }])
      stub_request(
        :get,
        "#{url}/Library?description=#{library_description}"
      ).to_return(status: 200, body: bundle.to_json)

      result = run(test, url:, library_description:)
      expect(result.result).to eq('fail')
    end

    it 'fails if the search request does not return a FHIR searchset bundle' do
      library =  FHIR::Library.new(description: library_description)
      stub_request(
        :get,
        "#{url}/Library?description=#{library_description}"
      ).to_return(status: 200, body: library.to_json)

      result = run(test, url:, library_description:)
      expect(result.result).to eq('fail')
    end
  end
end
