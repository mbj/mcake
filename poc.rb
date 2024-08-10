require 'adamantium'
require 'anima'
require 'variable'

Thread.abort_on_exception = true

class Cake
  include Adamantium, Anima.new(:targets)

  def self.empty
    new(targets: {})
  end

  class Target
    include Adamantium, Anima.new(:block, :dependencies, :name)
  end # Target

  def add_target_method(name, method)
    dependencies = method.parameters.map do |type, parameter_name|
      fail "Target: #{name} method: #{method.name} has invalid parameter type: #{parameter_name} #{type}" unless type.equal?(:keyreq)
      parameter_name
    end

    add_target(name, dependencies, method)
  end

  def add_target(name, dependencies, block)
    if targets.key?(name)
      fail "Target: #{target.name} already exists"
    end

    dependencies = dependencies.map do |dependency_name|
      targets.fetch(dependency_name) do
        fail "Target: #{name} has unknown dependency: #{dependency_name}"
      end
    end

    with(
      targets: targets.merge(name => Target.new(block:, dependencies:, name:))
    )
  end

  def builder
    results = targets.keys.map do |name|
      [
        name,
        Variable::IVar.new(condition_variable: ConditionVariable, mutex: Mutex)
      ]
    end.to_h

    Builder.new(targets:, results: )
  end

  class Builder
    include Anima.new(:targets, :results)

    def build(name)
      results.fetch(name).populate_with do
        target = targets.fetch(name)
        target.block.call(**build_dependencies(target))
      end
    end

  private

    def build_dependencies(target)
      target
        .dependencies
        .map { |dependency| Thread.new { [dependency.name, build(dependency.name)] } }
        .map(&:value)
        .to_h
    end
  end
end # Cake

def make_a0()
  p __method__
  p(__method__.tap { sleep 1 })
end

def make_a1()
  p __method__
  p(__method__.tap { sleep 1 })
end

def make_a2()
  p __method__
  p(__method__.tap { sleep 1 })
end

def make_b(a0:, a1:, a2:)
  p __method__
  :b_result
end

def make_c(a0:, b:)
  p __method__
  [:c_result, a0, b]
end

p Cake.empty
    .add_target_method(:a0, method(:make_a0))
    .add_target_method(:a1, method(:make_a1))
    .add_target_method(:a2, method(:make_a2))
    .add_target_method(:b, method(:make_b))
    .add_target_method(:c, method(:make_c))
    .builder
    .build(:c)


