module Kerbi
  module Config

    DIR_NAME = ".kerbi"
    FILE_NAME = "config.yaml"

    def self.file_path
      "#{Dir.home}/#{DIR_NAME}/#{FILE_NAME}"
    end

    def self.dir_path
      "#{Dir.home}/#{DIR_NAME}"
    end

    def self.create_file_if_missing
      unless File.exists?(file_path)
        unless Dir.exists?(dir_path)
          Dir.mkdir(dir_path)
        end
        File.touch(file_path)
      end
    end

    # @return [Hash{Symbol, String}]
    def self.read
      create_file_if_missing
      YAML.load_file(file_path).to_h.symbolize_keys
    end

    # @param [Hash] config
    def self.write(config)
      create_file_if_missing
      contents = YAML.dump(config.stringify_keys)
      File.write(file_path, contents)
    end

    # @param [Hash] config
    def self.patch(config)
      existing_config = read
      new_config = existing_config.merge(config)
      write(new_config)
    end
  end
end
