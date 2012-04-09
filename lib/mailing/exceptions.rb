module Mailing
  module Exceptions

    class Error < StandardError
    end

    class UnknownActionError < Error
      def initialize(mailer, action)
        @action = "#{mailer}##{action}"
      end
      def message
        "Action #{@action} does not exist. You should define it first."
      end
    end

    class MissingTemplateError < Error
      def initialize(mailer_instance)
        @action = "#{mailer_instance.class.name}##{mailer_instance.action_name}"
      end
      def message
        "Template for #{@action} not found. " \
        "You should define it manually or use Mailing.populate!"
      end
    end

  end
end