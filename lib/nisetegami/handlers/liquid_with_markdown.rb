class ActionView::Template::Handlers::LiquidWithMarkdown < ActionView::Template::Handlers::Liquid

  class_attribute :extensions
  self.extensions = {autolink: true, space_after_headers: true}

  def render(source, local_assigns = {})
    liquid = super
    @view.formats.include?(:html) ? renderer.render(liquid) : liquid
  end

  def renderer
    @_renderer ||= ::Redcarpet::Markdown.new(::Redcarpet::Render::HTML.new, extensions)
  end

end

ActionView::Template.register_template_handler :liquid_with_markdown, ActionView::Template::Handlers::LiquidWithMarkdown

