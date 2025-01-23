module Fastlane

	module Actions

		module SharedValues
			MATCH_CHECK_RESULTS = :MATCH_CHECK_RESULTS
		end

		class MatchCheckAction < Action

			def self.run(params)
				require 'app-info'

				FastlaneCore::PrintTable.print_values(
					config: params,
					title: 'Summary for match_check',
					mask_keys: []
				)

				profile_names = params[:names]
				directory = File.expand_path(params[:directory])
				files = Dir.glob("#{directory}/*.mobileprovision").sort_by { |f| File.mtime(f) }
				results = {}

				files.reverse_each do |file|
					profile = ::AppInfo.parse(file)
					name = profile.profile_name

					next unless profile_names.include?(name)
					diff = Fastlane::TimeDiff.new(Time.now, profile.expired_date)
					results[name] = diff
					profile_names.delete(name)
				end

				lane_context[:CHECK_PROFILES_RESULT] = results
				results
			end

			def self.default_profile_names
				mapping = lane_context[:MATCH_PROVISIONING_PROFILE_MAPPING]
				result = []
				result += mapping.values if mapping
				result
			end

			#####################################################
			# @!group Documentation
			#####################################################

			def self.description
				"Calculates time until each provisioning profile expires and automatically adds the result to Status"
			end

			def self.available_options
				[
					FastlaneCore::ConfigItem.new(
						key: :names,
						env_name: "MATCH_CHECK_NAMES",
						description: "Array of profile names to validate. Default value is pulled from match profile mapping",
						default_value_dynamic: true,
						default_value: self.default_profile_names
					),
					FastlaneCore::ConfigItem.new(
						key: :directory,
						env_name: "MATCH_CHECK_DIRECTORY",
						description: 'Path to directory where provisioning profiles are stored',
						default_value: '~/Library/MobileDevice/Provisioning Profiles/'
					)
				]
			end

			def self.output
				[
					['MATCH_CHECK_RESULTS', self.return_value]
				]
			end

			def self.return_value
				'A hash with each key as the name of the provisioning profile and a value describing how long until the profile expires'
			end

			def self.authors
				['UpBra']
			end

			def self.is_supported?(platform)
				[:ios, :mac].include?(platform)
			end
		end
	end

	class TimeDiff
		attr_accessor :months, :days, :hours, :minutes, :seconds

		def initialize(time1, time2)
			diff = time2 - time1
			@months, diff = diff.divmod(2_628_288)
			@days,  diff = diff.divmod(86_400)
			@hours, diff = diff.divmod(3_600)
			@mins,  diff = diff.divmod(60)
			@seconds = diff
		end

		def to_s
			components = ['Expires in']
			components << "#{@months} months" if @months > 0
			components << "#{@days} days" if @days > 0
			components.join(' ')
		end
	end
end
