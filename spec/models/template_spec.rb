require 'spec_helper'

describe Mailing::Template do

  it "has an actual factory" do
    FactoryGirl.create(:simple_mailing_template)
  end

  describe "headers" do
    before(:each) do
      @template = FactoryGirl.create(:simple_mailing_template)
      @recipient = "tester@example.org"
    end

    Mailing::Template::HEADERS.each do |header|
      context "defaults" do
        it "defaults #{header} do nil" do
          @template.send(header).should be_nil
        end

        it "does not include #{header} to the #headers" do
          @template.send("#{header}=", nil)
          @template.headers.should_not have_key(header.to_sym)
        end
      end

      ["Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net",
       "Mikel Lindsaar <mikel@test.lindsaar.net>",
       "ada@test.lindsaar.net"].each do |address|
        it "assumes that #{address} is a valid #{header}" do
          @template.send("#{header}=", address)
          @template.should be_valid
        end
      end

      ["Mikel Lindsaar mikel@test.lindsaar.net>, ada@ada@test.lindsaar.net",
       "Mikel Lindsaar mikel@test.lindsaar.net>",
       "ada@ada@test.lindsaar.net"].each do |address|
         it "assumes that #{address} is not a valid #{header}" do
           @template.send("#{header}=", address)
           @template.should_not be_valid
           @template.errors[header].should_not be_blank
         end
       end

      it "does not include #{header} to the #headers if it is blank" do
        @template.send("#{header}=", " ")
        @template.headers.should_not have_key(header.to_sym)
      end

      it "includes a valid #{header} to the #headers" do
        @template.send("#{header}=", 'Mikel Lindsaar <mikel@test.lindsaar.net>')
        @template.headers[header.to_sym].should == 'Mikel Lindsaar <mikel@test.lindsaar.net>'
      end
    end
  end

  describe "content" do
    before(:each) do
      @template = FactoryGirl.create(:simple_mailing_template)
    end

    Mailing::Template::CONTENT.each do |attribute|
      it "provides a #render_#{attribute} method" do
        content = @template.send("render_#{attribute}", fox: 'fox', dog: 'dog')
        content.should == "The quick brown fox jumps over the lazy dog."
      end

      it "requires #{attribute} to be a valid liquid template" do
        @template.send("#{attribute}=", "{{ invalid }")
        @template.should_not be_valid
      end

      it "ignores all variables wich are not in the #variable_names" do
        @template.send("#{attribute}=", "{{ fox }}, {{ dog }}, {{ unknown }}")
        content = @template.send("render_#{attribute}", fox: 'fox', dog: 'dog', unknown: 'unknown')
        content.should == 'fox, dog, '
      end
    end
  end

  describe "#message" do
    before(:each) do
      @template = FactoryGirl.create(:simple_mailing_template)
      @recipient = "tester@example.org"
    end

    it "generates an instance of Mail::Message" do
      @template.message(@recipient, fox: 'fox', dog: 'dog').should be_an_instance_of Mail::Message
    end

    it "overrides recipient (Mail::Message#to)" do
      @template.message(@recipient, fox: 'fox', dog: 'dog').to.should == [@recipient]
    end

    it "renders subject" do
      @template.update_attributes(subject: '{{ fox }} and {{ dog }}')
      @template.message(@recipient, dog: 'dog', fox: 'fox').subject.should == 'fox and dog'
    end

    context "when format of the template is HTML" do
      before { @template.update_attributes(:only_text => false) }

      context "when template disabled" do
        before(:each) do
          @template.update_attributes(enabled: false)
          @message = @template.message(@recipient, fox: 'fox', dog: 'dog')
        end

        specify { @template.should_not be_enabled }
        it_should_behave_like 'multipart template'
      end

      context "when template enabled" do
        before(:each) do
          @template.update_attributes(enabled: true)
          @message = @template.message(@recipient, fox: 'fox', dog: 'dog')
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
          @message = @template.message(@recipient, fox: 'fox', dog: 'dog')
        end

        specify { @template.should_not be_enabled }
        it_should_behave_like 'text template'
      end

      context "when template enabled" do
        before(:each) do
          @template.update_attributes(enabled: true)
          @message = @template.message(@recipient, fox: 'fox', dog: 'dog')
        end

        specify { @template.should be_enabled }
        it_should_behave_like 'text template'
      end
    end
  end
end