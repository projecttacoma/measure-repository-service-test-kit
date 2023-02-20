# frozen_string_literal: true

RSpec.describe MeasureRepositoryServiceTestKit::MeasurePackage do
  let(:suite) { Inferno::Repositories::TestSuites.new.find('measure_repository_service_test_suite') }
  let(:group) { suite.groups[5] }
  let(:session_data_repo) { Inferno::Repositories::SessionData.new }
  let(:test_session) { repo_create(:test_session, test_suite_id: suite.id) }
  let(:url) { 'http://example.com/fhir' }
  let(:data_requirements_reference_server) { 'http://example.com/reference/fhir' }
  let(:test_library_response) { FHIR::Library.new(dataRequirement: [{ type: 'Condition' }]) }
  let(:error_outcome) { FHIR::OperationOutcome.new(issue: [{ severity: 'error' }]) }
  let(:measure_id) { 'measure_id' }
  let(:invalid_id) { 'INVALID_ID' }
  let(:measure_url) { 'measure_url' }
  let(:measure_version) { 'measure_version' }
  let(:test_measure_response) { FHIR::Bundle.new(total: 1, entry: [{ resource: { id: measure_id } }]) }
  let(:test_measure) do
    FHIR::Measure.new(id: measure_id, url: measure_url, version: measure_version)
  end

  describe 'Server successfully returns Library matching reference server data requirements' do
    let(:test) { group.tests.first }

    it 'passes if the expected Library is received' do
      stub_request(:get, "#{url}/Measure/#{measure_id}")
        .to_return(status: 200, body: test_measure.to_json)

      stub_request(:get,
                   "#{data_requirements_reference_server}/Measure?url=#{measure_url}&version=#{measure_version}")
        .to_return(status: 200, body: test_measure_response.to_json)

      stub_request(
        :post,
        "#{data_requirements_reference_server}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: test_library_response.to_json)

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: test_library_response.to_json)

      result = run(test, url:,
                         measure_id:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('pass')
    end

    it 'passes for expected Library with a valueSet codefilter' do
      code_filters = [{ valueSet: 'testValueSet' }]
      value_set_library_response = FHIR::Library.new(dataRequirement: [{ type: 'Condition' }], codeFilter: code_filters)

      stub_request(:get, "#{url}/Measure/#{measure_id}")
        .to_return(status: 200, body: test_measure.to_json)

      stub_request(:get, "#{data_requirements_reference_server}/Measure" \
                         "?url=#{measure_url}&version=#{measure_version}")
        .to_return(status: 200, body: test_measure_response.to_json)

      stub_request(
        :post,
        "#{data_requirements_reference_server}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: value_set_library_response.to_json)

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: value_set_library_response.to_json)

      result = run(test, url:,
                         measure_id:,
                         data_requirements_reference_server:)
      expect(result.result).to eq('pass')
    end

    it 'passes for expected library with a single code codeFilter' do
      code_filters = [{ code: [{ code: 'testcode', system: 'testsystem' }] }]
      code_filter_library_response = FHIR::Library.new(dataRequirement: [{ type: 'Condition',
                                                                           codeFilter: code_filters }])
      test_measure = FHIR::Measure.new(id: measure_id, url: measure_url, version: measure_version)

      stub_request(:get, "#{url}/Measure/#{measure_id}")
        .to_return(status: 200, body: test_measure.to_json)

      stub_request(:get, "#{data_requirements_reference_server}/Measure" \
                         "?url=#{measure_url}&version=#{measure_version}")
        .to_return(status: 200, body: test_measure_response.to_json)

      stub_request(
        :post,
        "#{data_requirements_reference_server}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: code_filter_library_response.to_json)

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: code_filter_library_response.to_json)

      result = run(test, url:,
                         measure_id:,
                         data_requirements_reference_server:)
      expect(result.result).to eq('pass')
    end

    it 'fails if a different Library is received' do
      test_library_different = FHIR::Library.new(dataRequirement: [{ type: 'Observation' }])
      stub_request(:get, "#{url}/Measure/#{measure_id}")
        .to_return(status: 200, body: test_measure.to_json)

      stub_request(:get,
                   "#{data_requirements_reference_server}/Measure?url=#{measure_url}&version=#{measure_version}")
        .to_return(status: 200, body: test_measure_response.to_json)

      stub_request(
        :post,
        "#{data_requirements_reference_server}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: test_library_response.to_json)

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: test_library_different.to_json)

      result = run(test, url:,
                         measure_id:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end

    it 'fails if measure is not found on reference server' do
      empty_measure_response = FHIR::Bundle.new(total: 0, entry: [])
      stub_request(:get, "#{url}/Measure/#{measure_id}")
        .to_return(status: 200, body: test_measure.to_json)

      stub_request(:get,
                   "#{data_requirements_reference_server}/Measure?url=#{measure_url}&version=#{measure_version}")
        .to_return(status: 200, body: empty_measure_response.to_json)

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: test_library_response.to_json)

      result = run(test, url:,
                         measure_id:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end

    it 'fails if $data-requirements request to server under test returns 400' do
      stub_request(:get, "#{url}/Measure/#{measure_id}")
        .to_return(status: 200, body: test_measure.to_json)

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 400, body: test_library_response.to_json)

      result = run(test, url:,
                         measure_id:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end

    it 'fails if $data-requirements request to server under test returns non-Library resource' do
      stub_request(:get, "#{url}/Measure/#{measure_id}")
        .to_return(status: 200, body: test_measure.to_json)

      stub_request(
        :post,
        "#{url}/Measure/#{measure_id}/$data-requirements"
      )
        .to_return(status: 200, body: test_measure.to_json)

      result = run(test, url:,
                         measure_id:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns 200 and Library on $data-requirements with url' do
    let(:test) { group.tests[1] }

    it 'passes if 200 response returned with Library body given url and version' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 200, body: test_library_response.to_json)

      result = run(test, url:,
                         measure_url:,
                         measure_version:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('pass')
    end

    it 'passes if 200 response returned with Library body given just url' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 200, body: test_library_response.to_json)

      result = run(test, url:,
                         measure_url:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('pass')
    end

    it 'fails if 200 is not retuned' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 400, body: test_library_response.to_json)

      result = run(test, url:,
                         measure_url:,
                         measure_version:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end

    it 'fails if Library is not retuned' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 200, body: test_measure.to_json)

      result = run(test, url:,
                         measure_url:,
                         measure_version:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end
  end

  describe 'Server successfully returns 200 and Library on $data-requirements with identifier' do
    let(:test) { group.tests[2] }
    let(:measure_identifier) { 'testSystem|testCode' }

    it 'passes if 200 response returned with Library body' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 200, body: test_library_response.to_json)

      result = run(test, url:,
                         measure_identifier:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('pass')
    end

    it 'passes if 200 response returned with Library body given just url' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 200, body: test_library_response.to_json)

      result = run(test, url:,
                         measure_identifier:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('pass')
    end

    it 'fails if 200 is not retuned' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 400, body: test_library_response.to_json)

      result = run(test, url:,
                         measure_identifier:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end

    it 'fails if Library is not retuned' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 200, body: test_measure.to_json)

      result = run(test, url:,
                         measure_identifier:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end
  end

  describe 'Server throws 404 error for invalid measure id' do
    let(:test) { group.tests[3] }

    it 'passes if server returns 404 error with OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Measure/#{invalid_id}/$data-requirements"
      )
        .to_return(status: 404, body: error_outcome.to_json)

      result = run(test, url:,
                         measure_id: invalid_id,
                         data_requirements_reference_server:)

      expect(result.result).to eq('pass')
    end

    it 'fails if server returns 200' do
      stub_request(
        :post,
        "#{url}/Measure/#{invalid_id}/$data-requirements"
      )
        .to_return(status: 200, body: error_outcome.to_json)

      result = run(test, url:,
                         measure_id: invalid_id,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end

    it 'fails if server does not return OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Measure/#{invalid_id}/$data-requirements"
      )
        .to_return(status: 404, body: test_measure.to_json)

      result = run(test, url:,
                         measure_id: invalid_id,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end
  end

  describe 'Server throws 400 error for no identification info' do
    let(:test) { group.tests[4] }

    it 'passes if server returns 400 error with OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 400, body: error_outcome.to_json)

      result = run(test, url:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('pass')
    end

    it 'fails if server returns 200' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 200, body: error_outcome.to_json)

      result = run(test, url:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end

    it 'passes if server does not return OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Measure/$data-requirements"
      )
        .to_return(status: 200, body: test_measure.to_json)

      result = run(test, url:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end
  end

  describe 'Server throws 400 error for invalid parameter' do
    let(:test) { group.tests[5] }

    it 'passes if server returns 400 error with OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Measure/#{invalid_id}/$data-requirements?invalid=false"
      )
        .to_return(status: 400, body: error_outcome.to_json)

      result = run(test, url:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('pass')
    end

    it 'fails if server returns 200' do
      stub_request(
        :post,
        "#{url}/Measure/#{invalid_id}/$data-requirements?invalid=false"
      )
        .to_return(status: 200, body: error_outcome.to_json)

      result = run(test, url:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end

    it 'fails if server fails to return OperationOutcome' do
      stub_request(
        :post,
        "#{url}/Measure/#{invalid_id}/$data-requirements?invalid=false"
      )
        .to_return(status: 400, body: test_measure.to_json)

      result = run(test, url:,
                         data_requirements_reference_server:)

      expect(result.result).to eq('fail')
    end
  end
end
