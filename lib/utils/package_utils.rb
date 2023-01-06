# frozen_string_literal: true

require 'set'

module DEQMTestKit
  # Utility functions in support of the $package test group
  module PackageUtils
    def assert_related_artifacts_present(bundle)
      artifact_urls = Set[]
      bundle.entry.each do |e|
        next unless e.resource.resourceType == 'Library'

        e.relatedArtifact.each do |ra|
          artifact_urls.add(ra.url) if ra.type == 'depends-on'
        end
      end
      all_urls_present = artifact_urls.all? do |url|
        bundle.entry.any? do |e|
          e.resource.url == url
        end
      end
      assert(all_urls_present)
    end
  end
end
