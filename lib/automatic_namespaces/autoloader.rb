require 'yaml'

class AutomaticNamespaces::Autoloader
  ROOT_KEY = "automatic_pack_namespace".freeze
  PACKAGE_EXCLUDED_DIRS_KEY = "automatic_pack_namespace_exclusions".freeze
  PACKAGE_AUTOLOAD_GLOB_KEY_OLD = "autoload_glob".freeze
  PACKAGE_AUTOLOAD_GLOB_KEY = "automatic_pack_namespace_autoload_glob".freeze
  PACKAGE_NAMESPACE_OVERRIDE_KEY_OLD = "namespace_override".freeze

  DEFAULT_EXCLUDED_DIRS = %w[/app/helpers /app/inputs /app/javascript /app/views].freeze

  def enable_automatic_namespaces
    namespaced_packages.each do |pack, metadata|
      set_namespace_for_pack(pack, metadata)
    end
  end

  def set_namespace_for_pack(pack, metadata)
    package_namespace = define_namespace(pack, metadata)
    pack_directories(pack.path, metadata).each do |pack_dir|
      set_namespace_for_dir(pack_dir, package_namespace)
    end
  end

  private

  def set_namespace_for_dir(pack_dir, package_namespace)
    Rails.logger.debug { "Associating #{pack_dir} with namespace #{package_namespace}" }
    ActiveSupport::Dependencies.autoload_paths.delete(pack_dir)
    Rails.autoloaders.main.push_dir(pack_dir, namespace: package_namespace)
    Rails.application.config.watchable_dirs[pack_dir] = [:rb]
  end

  def pack_directories(pack_root_dir, metadata)
    glob = metadata[PACKAGE_AUTOLOAD_GLOB_KEY] || metadata[PACKAGE_AUTOLOAD_GLOB_KEY_OLD] || "/**/app/*"
    Dir.glob("#{pack_root_dir}#{glob}").select { |dir| namespaced_directory?(dir, metadata) }
  end

  def namespaced_directory?(dir, metadata)
    excluded_directories(metadata).none? { |excluded_dir| dir.include?(excluded_dir) }
  end

  def excluded_directories(metadata)
    DEFAULT_EXCLUDED_DIRS + metadata.fetch(PACKAGE_EXCLUDED_DIRS_KEY, [])
  end

  def define_namespace(pack, metadata)
    namespace_object = Object
    namespace_name(pack, metadata).split('::').each do |module_name|
      namespace_object = find_or_create_module(namespace_object, module_name)
    end
    namespace_object
  end

  def namespace_name(pack, metadata)
    if [true, false, "true", "false"].exclude?(metadata[ROOT_KEY])
      metadata[ROOT_KEY]
    else
      metadata[PACKAGE_NAMESPACE_OVERRIDE_KEY_OLD] || pack.last_name.camelize
    end
  end

  def find_or_create_module(namespace_object, module_name)
    namespace_object.const_defined?(module_name) ?
      namespace_object.const_get(module_name) :
      namespace_object.const_set(module_name, Module.new)
  end

  def namespaced_packages
    Packs.all
         .map {|pack| [pack, package_metadata(pack)] }
         .select {|_pack, metadata| metadata && metadata[ROOT_KEY] }
  end

  def package_metadata(pack)
    package_file = pack.path.join('package.yml').to_s
    package_description = YAML.load_file(package_file) || {}
    package_description["metadata"]
  end
end
