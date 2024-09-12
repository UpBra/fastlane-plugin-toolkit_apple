describe Fastlane::Actions::ToolkitAppleAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The toolkit_apple plugin is working!")

      Fastlane::Actions::ToolkitAppleAction.run(nil)
    end
  end
end
