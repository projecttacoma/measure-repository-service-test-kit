# frozen_string_literal: true

require 'pry'
require 'set'

module MeasureRepositoryServiceTestKit
  # Utility functions in support of the $package test group
  module PackageUtils
    def related_artifacts_present(bundle)
      artifact_urls = Set[]
      bundle.entry.each do |e|
        next unless e.resource.resourceType == 'Library'

        e.resource.relatedArtifact.each do |ra|
          if ra.type == 'depends-on' && ra.resource.include?('Library') && ra.resource != 'http://fhir.org/guides/cqf/common/Library/FHIR-ModelInfo|4.0.1'
            artifact_urls.add(ra.resource)
          end
        end
      end
      artifact_urls.all? do |url|
        if url.include? '|'
          split_reference = url.split('|')
          url = split_reference[0]
          version = split_reference[1]
        end
        bundle.entry.any? do |e|
          e.resource.url == url && e.resource.version == version
        end
      end
    end

    def retrieve_measure_from_bundle(measure_iden, iden_type, bundle)
      entry = bundle.entry.find do |e|
        e.resource.resourceType == 'Measure' && e.resource.send(iden_type) == measure_iden
      end
      return unless entry

      entry.resource
    end

    def measure_has_identifier(measure, identifier)
      iden_split = identifier.split('|')
      value = nil
      sys = nil
      if iden_split.length == 1
        value = iden_split[0]
      elsif iden_split[0] == ''
        value = iden_split[1]
      elsif iden_split[1] == ''
        sys = iden_split[0]
      else
        sys = iden_split[0]
        value = iden_split[1]
      end
      puts sys
      puts value
      measure.identifier.any? do |iden|
        puts iden.system
        puts iden.value
        does_match = true
        does_match &&= iden.value == value if !iden.value.nil? && value
        does_match &&= iden.system == sys if !iden.system.nil? && sys
        does_match
      end
    end
  end
end
