shared_examples_for "multipart template" do
  before do
    Mailing::TestMailer.delivery_method = :test
    Mailing::TestMailer.deliveries.clear
  end

  specify { @message.perform_deliveries.should == true }
  specify { @message.deliver; Mailing::TestMailer.deliveries.size.should == 1 }

  specify { @message.content_type.should =~ /^multipart\/alternative/}
  specify { @message.body.parts.size.should == 2 }

  it "renders a text/html part" do
    part = @message.body.parts.first
    part.content_type.should =~ /^text\/html/
    part.to_s.should include('The quick brown fox jumps over the lazy dog')
  end

  it "renders a text/plain part" do
    part = @message.body.parts.last
    part.content_type.should =~ /^text\/plain/
    part.to_s.should include('The quick brown fox jumps over the lazy dog')
  end
end

shared_examples_for "text template" do
  before do
    Mailing::TestMailer.delivery_method = :test
    Mailing::TestMailer.deliveries.clear
  end

  specify { @message.perform_deliveries.should == true }
  specify { @message.deliver; Mailing::TestMailer.deliveries.size.should == 1 }

  specify { @message.body.parts.should be_blank }
  specify { @message.content_type.should =~ /^text\/plain/ }

  it "renders a text/plain body" do
    @message.body.should include('The quick brown fox jumps over the lazy dog')
  end
end

shared_examples_for "disabled template" do
  before do
    Mailing::TestMailer.delivery_method = :test
    Mailing::TestMailer.deliveries.clear
  end

  specify { @message.perform_deliveries.should == false }
  specify { @message.deliver; Mailing::TestMailer.deliveries.size.should == 0 }

  specify { @message.body.parts.should be_blank }
  specify { @message.body.should be_blank }
end