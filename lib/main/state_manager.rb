module Kerbi
  class StateManager
    def self.patch
      self.create_configmap_if_missing
      patch_values = self.compile_patch
      config_map = utils::State.kubectl_get_cm("state", raise_on_err: false)
      crt_values = utils::State.read_cm_data(config_map)
      merged_vars = crt_values.deep_merge(patch_values)
      new_body = { **config_map, data: { variables: JSON.dump(merged_vars) } }
      yaml_body = YAML.dump(new_body.deep_stringify_keys)
      Utils::Kubectl.apply_tmpfile(yaml_body, args_manager.get_kmd_arg_str)
    end

    def compile_patch
      values = {}

      args_manager.get_fnames.each do |fname|
        new_values = YAML.load_file(fname).deep_symbolize_keys
        values.deep_merge!(new_values)
      end

      args_manager.get_inlines.each do |assignment_str|
        assignment = Utils::Utils.str_assign_to_h(assignment_str)
        values.deep_merge!(assignment)
      end
      values
    end

    def get_crt_vars
      create_configmap_if_missing
      get_configmap_values(get_configmap)
    end

    def create_configmap_if_missing
      unless get_configmap(raise_on_er: false)
        kmd = "create cm state #{args_manager.get_kmd_arg_str}"
        Utils::Kubectl.kmd(kmd)
      end
    end

    private

    def utils
      Kerbi::Utils
    end
  end
end