require 'adamantium'
require 'anima'
require 'variable'

module MCake
  require 'mcake/type_check'

  class Result
    include Adamantium, Anima.new(:value, :dependencies), TypeCheck

    def initialize(*)
      super

      assert_attributee_type(:dependencies, Hash)
    end

    def dependency(name)
      dependencies.fetch(name)
    end
  end

  class State
    include Adamantium::Flat, Anima.new(:targets), TypeCheck

    def initialize(*)
      super

      assert_attribute_type(:targets, Hash)
    end

    def add_target(target)
      name = target.name

      fail "Target name: #{name} is alread registered" if targets.key?(name)

      target.dependencies.each do |dependency_name|
        targets.fetch(dependency_name) do
          fail "Target: #{name} has unknown dependency: #{dependency_name}"
        end
      end

      targets[name] = target

      self
    end

    def build(name)
      assert_type(name, :name, Name)

      target = targets.fetch(name) { fail ArgumentError, "Unknown target: #{name}" }

      dependencies = target
        .dependencies
        .to_h { |dependency| [dependency.name, build_target(dependency.name)] }
        .transform_values(&:value)

      fail
    end

  private

    def new_ivar
      Variable::IVar.new(condition_variable: ConditionVariable, mutex: Mutex)
    end
  end # State

  class Name
    include Adamantium, Anima.new(:members), TypeCheck

    ALLOWED_MEMBERS = [Symbol, String, Integer].to_set.freeze

    private_constant(*constants(false))

    def self.build(member)
      new(members: [member])
    end

    def initialize(*)
      super

      assert_array_types(:members, ALLOWED_MEMBERS)

      fail ArgumentError, 'Name members cannot be empty' if members.empty?
    end

    def to_s
      members.join('-')
    end

    def extend(members)
      Name.new(members: component + members)
    end

    def keyword_argument?
      members.length.equal?(1) && members.fetch(0).instance_of?(Symbol)
    end
  end # Name

  def self.empty
    State.new(targets: {})
  end

  class Target
    include Adamantium, Anima.new(:block, :dependencies, :name), TypeCheck

    def initialize(attributes)
      super(attributes)

      assert_attribute_type(:block, Proc)
    end
  end # Target

  def self.name(name)
    Name.new(members: [name])
  end

end # MCake
