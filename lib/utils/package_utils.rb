# frozen_string_literal: true

require 'set'

module MeasureRepositoryServiceTestKit
  # Utility functions in support of the $cqfm.package test group
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
  end
end
