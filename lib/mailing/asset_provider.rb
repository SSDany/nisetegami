module Mailing
  class AssetProvider < Roadie::AssetProvider

    def find(name)
      asset_file(name.to_s).to_s.strip
    end

    private

    def asset_file(name)
      basename = remove_prefix(name)
      assets[File.join(Mailing.css_path, basename)] # FIXME
    end

    def assets
      Roadie.app.assets
    end

  end
end