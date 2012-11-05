class CreateNisetegamiTemplates < ActiveRecord::Migration
  def self.up
    create_table :nisetegami_templates do |t|

      ## mapping
      t.string :mailer # EG: "TestMailer"
      t.string :action # EG: "simple"
      t.string :name   # results in "TestMailer#simple"

      ## headers
      t.string :from
      t.string :cc
      t.string :bcc
      t.string :reply_to

      ## content
      t.text :subject
      t.text :body_text
      t.text :body_html
      t.text :layout_text
      t.text :layout_html

      ## controls
      t.boolean :enabled, null: false, default: false
      t.boolean :only_text, null: false, default: true

      t.timestamps
    end
    add_index :nisetegami_templates, [:mailer, :action], unique: true
  end

  def self.down
    drop_table :nisetegami_templates
  end
end
