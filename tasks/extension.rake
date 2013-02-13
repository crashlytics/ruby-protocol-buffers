spec = Bundler.load.specs.find { |gem| gem.name == 'ruby-protocol-buffers' }

require 'rake/extensiontask'
Rake::ExtensionTask.new do |ext|
  ext.name = 'varint'
  ext.ext_dir = 'ext/protocol_buffers'
  ext.gem_spec = spec
end
