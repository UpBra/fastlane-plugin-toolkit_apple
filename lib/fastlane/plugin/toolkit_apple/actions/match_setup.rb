module Fastlane

	module Actions

		class MatchSetupAction < Action

			module Key
				NAME = :keychain_name
				PASSWORD = :keychain_password
				UNLOCK = :keychain_unlock
				TIMEOUT = :keychain_timeout
				UNIQUE = :unique
			end

			def self.run(params)
				if lane_context.key?(SharedValues::KEYCHAIN_PATH)
					UI.message("Keychain already created. Skipping...")
					return
				end

				name = params[Key::NAME]
				password = params[Key::PASSWORD]
				unique = params[Key::UNIQUE]
				unlock = params[Key::UNLOCK]
				timeout = params[Key::TIMEOUT]

				components = [name]
				components << SecureRandom.alphanumeric(8) if unique && other_action.is_ci
				components << 'keychain'
				keychain_name = components.join('.')

				ENV['KEYCHAIN_NAME'] = keychain_name
				ENV['KEYCHAIN_PASSWORD'] = password
				ENV['MATCH_PASSWORD'] = password
				ENV['MATCH_KEYCHAIN_NAME'] = keychain_name
				ENV['MATCH_KEYCHAIN_PASSWORD'] = password

				other_action.create_keychain(
					name: keychain_name,
					unlock: unlock,
					timeout: timeout
				)

				# fix keychain path being set incorrectly (without the -db)
				keychain_path = FastlaneCore::Helper.keychain_path(keychain_name)
				lane_context[SharedValues::KEYCHAIN_PATH] = keychain_path

				UI.success("Created keychain at path: #{keychain_path}")
			end

			#####################################################
			# @!group Documentation
			#####################################################

			def self.description
				'Setup for Match'
			end

			def self.details
				'Creates a new keychain and sets all environment variables for Match'
			end

			def self.available_options
				[
					FastlaneCore::ConfigItem.new(
						key: Key::NAME,
						description: 'Name for the keychain',
						env_names: ['KEYCHAIN_NAME', 'MATCH_SETUP_KEYCHAIN_NAME'],
						optional: false
					),
					FastlaneCore::ConfigItem.new(
						key: Key::PASSWORD,
						description: 'Password for the keychain',
						env_names: ['KEYCHAIN_PASSWORD', 'MATCH_SETUP_KEYCHAIN_PASSWORD', 'PROJECT_PASSWORD'],
						type: String,
						optional: false
					),
					FastlaneCore::ConfigItem.new(
						key: Key::UNLOCK,
						description: 'Unlock keychain after create',
						env_name: 'MATCH_SETUP_KEYCHAIN_UNLOCK',
						type: Boolean,
						default_value: true
					),
					FastlaneCore::ConfigItem.new(
						key: Key::TIMEOUT,
						description: 'timeout interval in seconds. Set `0` if you want to specify "no time-out"',
						env_name: 'MATCH_SETUP_KEYCHAIN_TIMEOUT',
						type: Integer,
						default_value: 0
					),
					FastlaneCore::ConfigItem.new(
						key: Key::UNIQUE,
						description: 'Make keychain name unique',
						env_name: 'MATCH_SETUP_KEYCHAIN_UNIQUE',
						type: Boolean,
						default_value: true
					)
				]
			end

			def self.output
				[
					['ORIGINAL_DEFAULT_KEYCHAIN', 'The path to the default keychain'],
					['KEYCHAIN_PATH', 'The path of the keychain']
				]
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
