##
# Loads all dependencies for all Kerbi code.
#
require 'erb'
require "irb"
require 'json'
require 'yaml'
require 'time'
require "thor"
require 'open3'
require "base64"
require 'optparse'
require 'colorize'
require 'kubeclient'
require 'spicy-proton'
require 'terminal-table'

require 'active_support/inflector'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/indent.rb'
require 'active_support/core_ext/string/filters'
require 'active_support/callbacks'

require_relative './utils/misc'
require_relative './utils/k8s_auth'
require_relative './state/entry'
require_relative './cli/base_serializer'

require_relative './config/cli_schema'
require_relative './config/state_consts'
require_relative './config/config_file'
require_relative './config/globals'
require_relative './config/run_opts'

require_relative './mixins/mixer'
require_relative './mixins/cm_backend_testing'
require_relative './utils/cli'
require_relative './mixins/cli_state_helpers'

require_relative './utils/mixing'
require_relative './utils/helm'

require_relative './utils/values'
require_relative './main/code_gen'

require_relative './main/mixer'

require_relative './cli/entry_serializers'
require_relative './cli/release_serializer'

require_relative './mixins/entry_tag_logic'
require_relative './state/entry_set'

require_relative './state/base_backend'
require_relative './state/mixers'
require_relative './state/config_map_backend'

require_relative './revision/fetcher'

require_relative './main/errors'
require_relative './cli/base_handler'
require_relative './cli/config_handler'
require_relative './cli/values_handler'
require_relative './cli/project_handler'
require_relative './cli/state_handler'
require_relative './cli/release_handler'
require_relative './cli/root_handler'