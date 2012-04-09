require 'spec_helper'

describe Mailing::ActionMailerExtensions do
  before(:each) do
    @template = Factory(:simple_mailing_template)
  end

  context "when format of the template is HTML" do
    before { @template.update_attributes(:only_text => false) }

    context "when template disabled" do
      before(:each) do
        @template.update_attributes(enabled: false)
        @message = Mailing::TestMailer.send(@template.action, 'fox', 'dog')
      end

      specify { @template.should_not be_enabled }
      it_should_behave_like 'disabled template'
    end

    context "when template enabled" do
      before(:each) do
        @template.update_attributes(enabled: true)
        @message = Mailing::TestMailer.send(@template.action, 'fox', 'dog')
      end

      specify { @template.should be_enabled }
      it_should_behave_like 'multipart template'
    end
  end

  context "when format of the template is text" do
    before { @template.update_attributes(:only_text => true) }

    context "when template disabled" do
      before(:each) do
        @template.update_attributes(enabled: false)
        @message = Mailing::TestMailer.send(@template.action, 'fox', 'dog')
      end

      specify { @template.should_not be_enabled }
      it_should_behave_like 'disabled template'
    end

    context "when template enabled" do
      before(:each) do
        @template.update_attributes(enabled: true)
        @message = Mailing::TestMailer.send(@template.action, 'fox', 'dog')
      end

      specify { @template.should be_enabled }
      it_should_behave_like 'text template'
    end
  end
end