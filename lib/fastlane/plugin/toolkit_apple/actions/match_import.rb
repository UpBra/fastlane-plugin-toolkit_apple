module Fastlane

	module Actions

		class MatchImportAction < Action

			require 'match'

			def self.run(params)
				UI.user_error!('Cannot be run on CI') if Global.is_ci?

				password = ENV['PROJECT_PASSWORD']
				password ||= ENV['MATCH_PASSWORD']

				ENV['MATCH_PASSWORD'] = password

				params.load_configuration_file('Matchfile')

				begin
					params[:api_key] = other_action.app_store_connect_api_key()
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

				unless params[:dry_run]
					Dir.chdir('..') do
						::Match::Importer.new.import_cert(params)
					end
				end
			end

			#####################################################
			# @!group Documentation
			#####################################################

			def self.description
				'Entry to the match `import_cert` command'
			end

			def self.details
				'Allows you to utilize same mechanisms for `match` commands (loading Matchfile) when calling the import_cert command'
			end

			def self.available_options
				Match::Options.available_options + [
					FastlaneCore::ConfigItem.new(
						key: :dry_run,
						env_name: 'MATCH_IMPORT_DRY_RUN',
						description: 'Should we run the import command?',
						type: Boolean,
						default_value: false
					)
				]
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
