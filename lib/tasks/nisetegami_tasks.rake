namespace :nisetegami do
  namespace :templates do
    desc "Populate nisetegami templates with sample data"
    task populate: :environment do
      Nisetegami.populate!
    end
  end
end
