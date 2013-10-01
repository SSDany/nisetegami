class AddHandlerToNisetegamiTemplates < ActiveRecord::Migration
  def change
    add_column :nisetegami_templates, :handler, :string
    execute "UPDATE nisetegami_templates SET handler = 'liquid'"
  end
end
