##
# Loads all dependencies for all Kerbi code.
#
require 'erb'
require "irb"
require 'open3'
require 'json'
require 'yaml'
require "thor"
require "base64"
require 'optparse'
require 'colorize'
require 'kubeclient'

require 'active_support/concern'
require 'active_support/inflector'
require 'active_support/core_ext/object/deep_dup'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/deep_merge'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/indent.rb'

require_relative './utils/misc'
require_relative './utils/k8s_auth'

require_relative './config/cli_schema'
require_relative './config/manager'
require_relative './config/globals'
require_relative './config/cli_opts'

require_relative './mixins/mixer'

require_relative './utils/mixing'
require_relative './utils/helm'
require_relative './utils/kubectl'
require_relative './utils/cli'
require_relative './utils/values'
require_relative './main/code_gen'

require_relative './state/base'
require_relative './state/config_map'

require_relative './cli/base'
require_relative './cli/values_handler'
require_relative './cli/project_handler'
require_relative './cli/state_handler'
require_relative './cli/root_handler'
require_relative './main/mixer'

