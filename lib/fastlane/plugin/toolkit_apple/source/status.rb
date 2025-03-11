# -------------------------------------------------------------------------
#
# Post Status
# Posts status messages to multiple chat clients (Teams and Slack)
#
# -------------------------------------------------------------------------

module Status

	Actions = Fastlane::Actions
	SharedValues = Actions::SharedValues

	def self.add_testflight_facts
		return unless name ||= Actions.lane_context.fetch(SharedValues::TESTFLIGHT_DEPLOY_APP_DISPLAY_NAME)
		return unless value ||= Actions.lane_context.fetch(SharedValues::TESTFLIGHT_DEPLOY_ITUNES_URL)

		Status.add_fact(name, value)
	end
end