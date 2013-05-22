require 'spec_helper'

describe Nisetegami::TemplatesController do
  let!(:template) { FactoryGirl.create(:simple_nisetegami_template) }

  describe "#index" do
    it "renders index page when filters are not applied" do
      get :index, use_route: :nisetegami
      response.should be_success
      assigns(:templates).should be_present
    end

    it "renders index page when filters are applied" do
      2.times { FactoryGirl.create(:simple_nisetegami_template, enabled: true) }
      get :index, enabled: 'true', use_route: :nisetegami
      response.should be_success
      assigns(:templates).should be_present
      assigns(:templates).count.should == 2
    end
  end

  it "renders actions as json" do
    post :actions, mailer: 'Nisetegami::TestMailer', use_route: :nisetegami
    response.should be_success
    response.body.should == ([''] + Nisetegami.mapping.actions('Nisetegami::TestMailer')).to_json
  end

  it "renders edit page" do
    get :edit, id: template.id, use_route: :nisetegami
    response.should be_success
    assigns(:template).should be_present
  end

  describe "#update" do
    it "updates template if params are valid" do
      post :update, id: template.id, subject: 'Bogus', use_route: :nisetegami
      response.should redirect_to('/mail/')
      assigns(:template).should be_present
      flash[:notice].should be_present
    end

    it "renders edit page if params are not valid" do
      template.update_column :enabled, true
      post :update, id: template.id, template: {subject: ''}, use_route: :nisetegami
      response.should be_success
      response.should render_template('edit')
      assigns(:template).should be_present
    end
  end

  it "destroys template" do
    template2 = FactoryGirl.create(:simple_nisetegami_template)
    expect do
      delete :destroy, template_ids: [template.id, template2.id], use_route: :nisetegami
    end.to change(Nisetegami::Template, :count).by(-2)
    response.should redirect_to('/mail/')
    flash[:notice].should be_present
  end

  describe "#test" do
    it "sends email if address is valid" do
      post :test, id: template.id, recipient: 'bogus@test.com', use_route: :nisetegami
      response.should redirect_to("/mail/#{template.id}/edit")
      flash[:notice].should be_present
      flash[:alert].should be_nil
    end

    it "does not send email if address if invalid" do
      post :test, id: template.id, recipient: 'bogus', use_route: :nisetegami
      response.should redirect_to("/mail/#{template.id}/edit")
      flash[:notice].should be_nil
      flash[:alert].should be_present
    end
  end
end
