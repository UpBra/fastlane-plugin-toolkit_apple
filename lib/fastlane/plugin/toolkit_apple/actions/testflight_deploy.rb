module Fastlane

	module Actions

		module SharedValues
			TESTFLIGHT_DEPLOY_APP_DISPLAY_NAME = :TESTFLIGHT_DEPLOY_CUSTOM_VALUE
			TESTFLIGHT_DEPLOY_ITUNES_URL = :TESTFLIGHT_DEPLOY_ITUNES_URL
		end

		class TestflightDeployAction < Action

			FastlaneRequire.install_gem_if_needed(gem_name: 'fastlane-plugin-app_info', require_gem: true)

			def self.run(params)
				available = Fastlane::Actions::TestflightAction.available_options.map(&:key)
				options = params.values.clone.keep_if { |k,v| available.include?(k) }
				options.transform_keys(&:to_sym)

				FastlaneCore::PrintTable.print_values(
					config: options,
					title: 'Summary for testflight_deploy',
					mask_keys: [:api_key, :api_key_path]
				)

				ipa = options.fetch(:ipa)
				info = ::AppInfo.parse(ipa)

				options[:app_identifier] ||= info.bundle_id
				options[:skip_waiting_for_build_processing] ||= true

				unless Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY]
					other_action.app_store_connect_api_key
				end

				other_action.testflight(options)

				name = [info.name, info.release_version, "(#{info.build_version})"].join(' ')
				lane_context[SharedValues::TESTFLIGHT_DEPLOY_APP_DISPLAY_NAME] = name

				identifier = options[:apple_id]
				lane_context[SharedValues::TESTFLIGHT_DEPLOY_ITUNES_URL] = "https://itunes.apple.com/us/app/keynote/id#{identifier}"
			end

			#####################################################
			# @!group Documentation
			#####################################################

			def self.description
				'Wrapper for the TestFlight upload'
			end

			def self.details
				'Calls app_store_connect_api_key for you. Will set bundle_id from the value in the ipa file. Constructs app display name and itunes connect url link'
			end

			def self.available_options
				Fastlane::Actions::TestflightAction.available_options
			end

			def self.output
				[
					['TESTFLIGHT_DEPLOY_CUSTOM_VALUE', 'A description of what this value contains']
				]
			end

			def self.return_value
			end

			def self.authors
				['UpBra']
			end

			def self.is_supported?(platform)
				platform == :ios
			end
		end
	end
end
