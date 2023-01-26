# frozen_string_literal: true

require 'set'

module MeasureRepositoryServiceTestKit
  # Utility functions in support of the $package test group
  module PackageUtils
    def related_artifacts_present?(bundle, should_check_valuesets)
      artifact_urls = Set[]
      bundle.entry.each do |e|
        next unless e.resource.resourceType == 'Library'

        add_artifact_urls(artifact_urls, e.resource, should_check_valuesets)
      end
      artifact_in_bundle?(artifact_urls, bundle)
    end

    def add_artifact_urls(artifact_urls, resource, should_check_valuesets)
      resource.relatedArtifact.each do |ra|
        artifact_urls.add(ra.resource) if ra.type == 'depends-on' && ra.resource.include?('Library')
        next unless should_check_valuesets

        artifact_urls.add(ra.resource) if ra.type == 'depends-on' && ra.resource.include?('ValueSet')
      end
    end

    def artifact_in_bundle?(artifact_urls, bundle)
      artifact_urls.all? do |url|
        if url.include? '|'
          split_reference = url.split('|')
          url = split_reference[0]
          version = split_reference[1]
        end
        bundle.entry.any? do |e|
          e.resource.url == url && (!version || e.resource.version == version)
        end
      end
    end

    # rubocop:disable Metrics/MethodLength
    def retrieve_measure_from_bundle(measure_iden, iden_type, bundle)
      entry =
        bundle.entry.find do |e|
          if e.resource.resourceType == 'Measure'
            if iden_type == 'identifier'
              resource_has_matching_identifier?(e.resource, measure_iden)
            else
              e.resource.send(iden_type) == measure_iden
            end
          end
        end
      return unless entry

      entry.resource
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def retrieve_root_library_from_bundle(library_iden, iden_type, bundle)
      entry =
        bundle.entry.find do |e|
          if e.resource.resourceType == 'Library'
            if iden_type == 'identifier'
              resource_has_matching_identifier?(e.resource, library_iden)
            else
              e.resource.send(iden_type) == library_iden
            end
          end
        end
      return unless entry

      entry.resource
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/CyclomaticComplexity
    def resource_has_matching_identifier?(resource, identifier)
      sys, value = split_identifier(identifier)
      resource.identifier.any? do |iden|
        does_match = true
        does_match &&= iden.value == value if !iden.value.nil? && value
        does_match &&= iden.system == sys if !iden.system.nil? && sys
        does_match
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    # rubocop:disable Metrics/MethodLength
    def split_identifier(identifier)
      iden_split = identifier.split('|')
      value = sys = nil
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
      [sys, value]
    end
    # rubocop:enable Metrics/MethodLength
  end
end
