class ActionView::Template::Handlers::Liquid

  def self.call(template)
    "#{self.name}.new(self).render(#{template.source.inspect}, local_assigns)"
  end

  def initialize(view)
    @view = view
  end

  def render(source, local_assigns = {})
    assigns = @view.assigns
    assigns["content_for_layout"] = @view.content_for(:layout) if @view.content_for?(:layout)
    assigns.merge!(local_assigns.stringify_keys)

    controller = @view.controller
    filters = if controller.respond_to?(:liquid_filters, true)
        controller.send(:liquid_filters)
      elsif controller.respond_to?(:master_helper_module)
        [controller.master_helper_module]
      elsif controller.respond_to?(:_helpers)
        [controller._helpers]
      else
        []
      end

    liquid = Liquid::Template.parse(source)
    liquid.render(assigns, filters: filters, registers: { action_view: @view, controller: @view.controller })
  end

  def compilable?
    false
  end
end

ActionView::Template.register_template_handler :liquid, ActionView::Template::Handlers::Liquid
