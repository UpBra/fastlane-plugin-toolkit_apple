describe Fastlane::Helper::ToolkitAppleHelper do
	describe '#run' do
		it 'prints a message' do
			expect(Fastlane::UI).to receive(:message).with("Hello from the toolkit_apple plugin helper!")

			Fastlane::Helper::ToolkitAppleHelper.show_message
		end
	end
end


# describe Fastlane::Actions::ToolkitAppleAction do
# 	describe '#run' do
# 		it 'prints a message' do
# 			expect(Fastlane::UI).to receive(:message).with("The toolkit_apple plugin is working!")

# 			Fastlane::Actions::ToolkitAppleAction.run(nil)
# 		end
# 	end
# end
