module Fastlane

	module Actions

		module SharedValues
			CHECK_XCODE_SDKS_CUSTOM_VALUE = :CHECK_XCODE_SDKS_CUSTOM_VALUE
		end

		class CheckXcodeSdksAction < Action

			def self.run(params)
				xcodes = Action.sh('xcodes installed', print_command: false, print_command_output: false)
				xcodes = xcodes.split("\n").map { |row|
					items = row.split("\t")

					{
						version: items.first,
						path: items.last
					}
				}

				xcodes.each { |xcode|
					# set the shell version `xcodes(version: nnn)`
					version = xcode.fetch(:version).split(/\s/).first

					next unless version == "15.0.1"

					other_action.xcodes(version: version, select_for_current_build_only: true)

					# get all the sdks `xcodebuild -showsdks -json`
					sdks = Action.sh(
						'xcrun xcodebuild -showsdks -json',
						print_command: false,
						print_command_output: false
					)

					sdks = JSON.parse(sdks, symbolize_names: true)

					# check that each sdk is installed	`xcodebuild -version -sdk nnn`
					errors = []

					sdks.each { |sdk|
						# begin
							next unless sdk.fetch(:isBaseSdk)
							# next unless sdk.fetch(:platform) == "watchos"

							name = sdk.fetch(:canonicalName)
							display_name = sdk.fetch(:displayName)

							command = []
							command << 'xcrun'
							command << 'xcodebuild'
							command << '-version'
							command << '-sdk'
							command << name
							command = command.join(" ")

							result = Action.sh(
								command,
								print_command: true,
								print_command_output: false,
								error_callback: Proc.new do |result|
									UI.error result
								end
							)

							UI.message result
							UI.success display_name
						# rescue => error
							# message = result.split(/\n/).last
							# UI.error message
							# errors << error
						# end

						UI.message sdk
					}

					UI.user_error! "One or more sdk is not installed!" unless errors.empty?
				}
			end

			#####################################################
			# @!group Documentation
			#####################################################

			def self.description
				'A short description with <= 80 characters of what this action does'
			end

			def self.details
				'You can use this action to do cool things...'
			end

			def self.available_options
				[
					FastlaneCore::ConfigItem.new(
						key: :api_token,
						env_name: 'FL_CHECK_XCODE_SDKS_API_TOKEN',
						description: 'API Token for CheckXcodeSdksAction',
						default_value: 'hello'
					),
					FastlaneCore::ConfigItem.new(
						key: :development,
						env_name: 'FL_CHECK_XCODE_SDKS_DEVELOPMENT',
						description: 'Create a development certificate instead of a distribution one',
						is_string: false,
						default_value: false
					)
				]
			end

			def self.output
				[
					['CHECK_XCODE_SDKS_CUSTOM_VALUE', 'A description of what this value contains']
				]
			end

			def self.return_value
				# If your method provides a return value, you can describe here what it does
			end

			def self.authors
				['WTA']
			end

			def self.is_supported?(platform)
				platform == :ios
			end
		end
	end
end
