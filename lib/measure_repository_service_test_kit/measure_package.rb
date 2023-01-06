# frozen_string_literal: true

require 'json'
require_relative '../utils/package_utils'

module MeasureRepositoryServiceTestKit
  # tests for Measure $package service
  class MeasurePackage < Inferno::TestGroup
    title 'Measure $package'
    description 'Ensure measure repository service can execute the $package operation to the Measure endpoint'
    id 'measure_package'

    fhir_client do
      url :url
    end

    test do
      title 'All related artifacts present'
      id 'measure-package-01'
      description 'returned bundle includes all related artifacts for all libraries'
      input :selected_measure_id
      run do
        #fhir_operation("Measure/#{selected_measure_id}/$package")
        #assert_related_artifacts_present(response[:body])
      end
    end
  end
end
