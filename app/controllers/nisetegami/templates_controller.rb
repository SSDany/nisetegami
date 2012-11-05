require_dependency "nisetegami/application_controller"

module Nisetegami
  class TemplatesController < ApplicationController
    def index
      @templates = Template.all
    end

    def show
      @template = Template.find(params[:id])
    end

    def edit
      @template = Template.find(params[:id])
    end

    def update
      @template = Template.find(params[:id])
      if @template.update_attributes(params[:template])
        redirect_to({action: :index}, notice: t('nisetegami.template.updated'))
      else
        render action: :edit
      end
    end

    def destroy
      Template.find(params[:id]).destroy
    end

    def populate
      Nisetegami.populate!
    end

    def test
      template = Template.find(params[:id])
      message = unless params[:recipient] =~ Nisetegami.email_regexp
          {alert: t('nisetegami.wrong_email')}
        else
          template.message(params[:recipient], params[:template]).deliver
          {notice: t('nisetegami.test_delivered')}
        end
      redirect_to :back, message
    end
  end
end
