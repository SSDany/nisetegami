module Nisetegami
  class AssetProvider < Roadie::AssetPipelineProvider

    def exists?(name)
      !asset_file(name).nil?
    end

    def asset_file(name)
      basename = remove_prefix(name)
      assets[basename]
    end

  end
end
