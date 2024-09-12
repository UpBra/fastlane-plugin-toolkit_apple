module Fastlane

	module Actions

		module SharedValues
			MATCH_IMPORT_CUSTOM_VALUE = :MATCH_IMPORT_CUSTOM_VALUE
		end

		class MatchImportAction < Action

			module Key
				PASSWORD = :password
			end

			def self.run(params)
				require 'match'

				UI.user_error!('Cannot be run on CI') if Global.is_ci

				password = params[Key::PASSWORD]
				Environment[:MATCH_PASSWORD] = password

				platform = MatchSetup.platforms.first
				platform = UI.select('Platform?', MatchSetup.platforms) unless MatchSetup.platforms.count == 1

				configuration = MatchSetup.configurations.first
				configuration = UI.select('Configuration?', MatchSetup.configurations) unless MatchSetup.configurations.count == 1

				MatchSetup.configure(platform, configuration)

				params = FastlaneCore::Configuration.create(::Match::Options.available_options, {})
				params.load_configuration_file('Matchfile')

				begin
					params[:api_key] = app_store_connect_api_key
				rescue StandardError
					username = params.fetch(:username)

					if username.nil?
						username = UI.input('App Store Username?')
						params[:username] = username
					end
				end

				FastlaneCore::PrintTable.print_values(
					config: params,
					title: "Match Import Summary"
				)

				unless options[:dry_run]
					Dir.chdir('..') do
						::Match::Importer.new.import_cert(params)
					end
				end
			end

			#####################################################
			# @!group Documentation
			#####################################################

			def self.description
				'A short description with <= 80 characters of what this action does'
			end

			def self.details
				# Optional:
				# this is your chance to provide a more detailed description of this action
				'You can use this action to do cool things...'
			end

			def self.available_options
				[
					FastlaneCore::ConfigItem.new(
						key: Key::PASSWORD,
						env_names: ['MATCH_PASSWORD', 'PROJECT_PASSWORD'],
						description: 'Match password'
					)
				]
			end

			def self.output
				[
					['TLK_MATCH_IMPORT_CUSTOM_VALUE', 'A description of what this value contains']
				]
			end

			def self.return_value
				# If your method provides a return value, you can describe here what it does
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
