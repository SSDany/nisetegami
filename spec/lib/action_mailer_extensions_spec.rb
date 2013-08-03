require 'spec_helper'

describe Nisetegami::ActionMailerExtensions do
  before do
    @template = FactoryGirl.create(:simple_nisetegami_template)
  end

  context "when format of the template is HTML" do
    before { @template.update_attributes(only_text: false) }

    context "when template disabled" do
      before do
        @template.update_attributes(enabled: false)
        @message = Nisetegami::TestMailer.send(@template.action, 'fox', 'dog')
      end

      specify { @template.should_not be_enabled }
      it_should_behave_like 'disabled template'
    end

    context "when template enabled" do
      before do
        @template.update_attributes(enabled: true)
        @message = Nisetegami::TestMailer.send(@template.action, 'fox', 'dog')
      end

      specify { @template.should be_enabled }
      it_should_behave_like 'multipart template'
    end

    context "when template enabled, but mail delivery is disabled on the application level" do
      before do
        ActionMailer::Base.perform_deliveries = false
        @template.update_attributes(enabled: true)
        @message = Nisetegami::TestMailer.send(@template.action, 'fox', 'dog')
      end

      after do
        ActionMailer::Base.perform_deliveries = true
      end

      it_should_behave_like 'disabled template'
    end
  end

  context "when format of the template is text" do
    before { @template.update_attributes(only_text: true) }

    context "when template disabled" do
      before do
        @template.update_attributes(enabled: false)
        @message = Nisetegami::TestMailer.send(@template.action, 'fox', 'dog')
      end

      specify { @template.should_not be_enabled }
      it_should_behave_like 'disabled template'
    end

    context "when template enabled" do
      before do
        @template.update_attributes(enabled: true)
        @message = Nisetegami::TestMailer.send(@template.action, 'fox', 'dog')
      end

      specify { @template.should be_enabled }
      it_should_behave_like 'text template'
    end

    context "when template enabled, but mail delivery is disabled on the application level" do
      before do
        ActionMailer::Base.perform_deliveries = false
        @template.update_attributes(enabled: true)
        @message = Nisetegami::TestMailer.send(@template.action, 'fox', 'dog')
      end
      
      after do
        ActionMailer::Base.perform_deliveries = true
      end

      it_should_behave_like 'disabled template'
    end
  end
end
