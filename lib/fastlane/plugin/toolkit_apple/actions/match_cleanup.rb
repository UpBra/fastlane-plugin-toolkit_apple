module Fastlane

	module Actions

		class MatchCleanupAction < Action

			module Key
				RESET = :keychain_reset
			end

			def self.run(params)
				keychain_path = lane_context[SharedValues::KEYCHAIN_PATH]

				if keychain_path
					other_action.delete_keychain(
						keychain_path: keychain_path
					)
					lane_context.delete(SharedValues::KEYCHAIN_PATH)
				end

				if params[Key::RESET]
					login_keychain = File.expand_path('~/Library/Keychains/login.keychain')
					Fastlane::Actions.sh("security list-keychains -s #{login_keychain.shellescape}", log: false)
				end

				Fastlane::Actions.sh('security list-keychains', log: true)
			end

			#####################################################
			# @!group Documentation
			#####################################################

			def self.description
				'Cleanup for Match Setup'
			end

			def self.details
				'Deletes the keychain created by match setup and resets keychains to just the login keychain'
			end

			def self.available_options
				[
					FastlaneCore::ConfigItem.new(
						key: Key::RESET,
						env_name: 'TLK_KEYCHAIN_CLEANUP_RESET',
						description: 'Create a development certificate instead of a distribution one',
						type: Boolean,
						default_value: true
					)
				]
			end

			def self.output
				[]
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
