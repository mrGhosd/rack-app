require "rack/builder"
class Rack::App::Endpoint::Builder

  def initialize(config)
    @config = config
  end

  def build
    builder = Rack::Builder.new
    apply_middleware_build_blocks(builder)
    @config.endpoint_method_name
    builder.run(Rack::App::Endpoint::Executor.new(@config))
    builder.to_app
  end

  protected

  def apply_middleware_build_blocks(builder)
    builder_blocks.each do |builder_block|
      builder_block.call(builder)
    end
    builder.use(Rack::App::Middlewares::Configuration, @config.to_hash)
    apply_hook_middlewares(builder)
  end

  def apply_hook_middlewares(builder)
    @config.app_class.before.each do |before_block|
      builder.use(Rack::App::Middlewares::Hooks::Before, before_block)
    end
    @config.app_class.after.each do |after_block|
      builder.use(Rack::App::Middlewares::Hooks::After, after_block)
    end
  end

  def builder_blocks
    @config.app_class.middlewares + @config.middleware_builders_blocks
  end

end
