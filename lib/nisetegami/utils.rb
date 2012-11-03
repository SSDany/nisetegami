module Nisetegami
  module Utils
    module_function

    def liquid_methods_for(thing)
      return nil unless thing.const_defined?('LiquidDropClass')
      thing::LiquidDropClass.public_instance_methods(false)
    end

    def filenames(path, format)
      Dir[File.join(path, "*.#{format}.*")].map { |file|
        File.basename(file).sub(/\.#{format}#{File.extname(file)}$/, "")
      }.uniq
    end

  end
end
