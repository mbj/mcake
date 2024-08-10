require 'adamantium'
require 'anima'
require 'variable'

class MCake
  include Adamantium::Flat, Anima.new(:targets, :results)

  def self.empty
    new(targets: {}, results: {})
  end

  class Target
    include Adamantium, Anima.new(:block, :dependencies, :name)
  end # Target

  def add_target_block(name, &block)
    dependencies = block.parameters.map do |type, parameter_name|
      unless type.equal?(:keyreq)
        fail "Target: #{name} "                                 \
             "block #{block} "                                  \
             "has invalid parameter #{parameter_name.inspect} " \
             "of type: #{type} "                                \
             "expected :keyreq"
      end

      parameter_name
    end

    add_target(name, dependencies, block)
  end

  def add_target_method(name, method)
    dependencies = method.parameters.map do |type, parameter_name|
      unless type.equal?(:keyreq)
        fail "Target: #{name} "                                 \
             "method: #{method.name} "                          \
             "has invalid parameter #{parameter_name.inspect} " \
             "of type: #{type} "                                \
             "expected :keyreq"
      end

      parameter_name
    end

    add_target(name, dependencies, method)
  end

  def add_target(name, dependencies, block)
    if targets.key?(name)
      fail "Target: #{name} already exists"
    end

    dependencies = dependencies.map do |dependency_name|
      targets.fetch(dependency_name) do
        fail "Target: #{name} has unknown dependency: #{dependency_name}"
      end
    end

    with(
      targets: targets.merge(name => Target.new(block:, dependencies:, name:)),
      results: results.merge(name => new_ivar)
    )
  end

  def build(name)
    build_target(name).value
  end

  private

  def new_ivar
    Variable::IVar.new(condition_variable: ConditionVariable, mutex: Mutex)
  end

  def build_target(name)
    results
      .fetch(name)
      .populate_with do
        Thread.new do
          target = targets.fetch(name)
          target.block.call(**build_dependencies(target))
        end
      end
  end

  def build_dependencies(target)
    target
      .dependencies
      .to_h { |dependency| [dependency.name, build_target(dependency.name)] }
      .transform_values(&:value)
  end
end # MCake
