class ActionView::Template::Handlers::ERBWithMarkdown < ActionView::Template::Handlers::ERB

  class_attribute :extensions
  self.extensions = {autolink: true, space_after_headers: true}

  def self.renderer
    @_renderer ||= ::Redcarpet::Markdown.new(::Redcarpet::Render::HTML.new, extensions)
  end

  def call(template)
    super + ";#{self.class.name}.renderer.render(@output_buffer.to_s)"
  end

end

ActionView::Template.register_template_handler :erb_with_markdown, ActionView::Template::Handlers::ERBWithMarkdown

