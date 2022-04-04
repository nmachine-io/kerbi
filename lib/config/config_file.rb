module Kerbi

  module ConfigFile

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
        write({}, skip_check: true)
      end
    end

    # @return [Hash{Symbol, String}]
    def self.read
      begin
        create_file_if_missing
        contents = YAML.load_file(file_path)
        contents.slice(*legal_keys)
      rescue StandardError => e
        puts "[WARN] failed to read config #{file_path} (#{e})"
        {}
      end
    end

    # @param [Hash] config
    def self.write(config, skip_check: false)
      create_file_if_missing unless skip_check
      config = config.deep_dup.stringify_keys.slice(*legal_keys)
      File.write(file_path, YAML.dump(config))
    end

    # @param [Hash] config
    def self.patch(config)
      existing_config = read
      new_config = existing_config.merge(config)
      write(new_config)
    end

    def self.legal_keys
      Kerbi::Consts::OptionKeys::LEGAL_CONFIG_FILE_KEYS
    end
  end
end
