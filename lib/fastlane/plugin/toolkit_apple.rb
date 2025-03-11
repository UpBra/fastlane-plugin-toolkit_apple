require 'fastlane/plugin/toolkit_apple/version'

module Fastlane

	module ToolkitApple

		def self.all_classes
			Dir[File.expand_path('**/{actions,helper,source}/*.rb', File.dirname(__FILE__))]
		end
	end
end

Fastlane::ToolkitApple.all_classes.each do |current|
	require current
end
