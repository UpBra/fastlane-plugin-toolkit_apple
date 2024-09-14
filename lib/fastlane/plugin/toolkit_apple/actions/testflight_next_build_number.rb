module Fastlane

	module Actions

		module SharedValues
			TESTFLIGHT_NEXT_BUILD_NUMBER = :TESTFLIGHT_NEXT_BUILD_NUMBER
		end

		class TestflightNextBuildNumberAction < Action

			def self.run(params)
				FastlaneCore::PrintTable.print_values(
					config: params,
					title: 'Summary for testflight_next_build_number',
					mask_keys: [:api_key, :api_key_path]
				)

				unless Actions.lane_context[SharedValues::APP_STORE_CONNECT_API_KEY]
					other_action.app_store_connect_api_key
				end

				available = Fastlane::Actions::LatestTestflightBuildNumberAction.available_options.map(&:key)
				options = params.values.clone.keep_if { |k,v| available.include?(k) }
				options.transform_keys(&:to_sym)
				options[:initial_build_number] = '0'

				begin
					options[:live] = false
					other_action.latest_testflight_build_number(options)
					testflight = lane_context[SharedValues::LATEST_TESTFLIGHT_BUILD_NUMBER].to_s

					options[:live] = true
					other_action.app_store_build_number(options)
					appstore = lane_context[SharedValues::LATEST_BUILD_NUMBER].to_s
				rescue StandardError
					testflight = lane_context.fetch(SharedValues::LATEST_TESTFLIGHT_BUILD_NUMBER, '0')
					appstore = lane_context.fetch(SharedValues::LATEST_BUILD_NUMBER, '0')
				end

				build_number = [testflight, appstore].map(&:to_i).max
				build_number = build_number.next

				lane_context[SharedValues::TESTFLIGHT_NEXT_BUILD_NUMBER] = build_number.to_s
			end

			#####################################################
			# @!group Documentation
			#####################################################

			def self.description
				'Returns the next build number to use by fetching the latest build from Testflight and incrementing it by 1'
			end

			def self.available_options
				Fastlane::Actions::LatestTestflightBuildNumberAction.available_options
			end

			def self.output
				[
					['TESTFLIGHT_NEXT_BUILD_NUMBER', self.return_value]
				]
			end

			def self.return_value
				'The next build number to use'
			end

			def self.authors
				['UpBra']
			end

			def self.is_supported?(_)
				true
			end
		end
	end
end
