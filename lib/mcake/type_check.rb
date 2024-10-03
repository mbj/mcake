module MCake
  module TypeCheck
  private
    def assert_type(value, identification, expected_class)
      klass = value.class

      unless klass.equal?(expected_class)
        fail TypeError, "#{identification} expected class: #{expected_class}, got: #{klass}"
      end
    end

    def assert_attribute_type(attribute_name, expected_class)
      klass = __send__(attribute_name).class

      unless expected_class.equal?(klass)
        fail TypeError, "#{self.class.name}##{attribute_name} allowed class: #{expected_class} got: #{klass}"
      end
    end

    def assert_attribute_types(attribute_name, allowed_classes)
      klass = __send__(attribute_name).class

      unless allowed_classes.include?(klass)
        fail TypeError, "#{self.class.name}##{attribute_name} allowed classes: #{allowed_classes.join(', ')} got: #{klass}"
      end
    end

    def assert_array_type(attribute_name, expected_class)
      assert_attribute_type(attribute_name, Array)

      __send__(attribute_name).each do |value|
        klass = value.class

        unless expected_class.equal?(klass)
          fail TypeError, "#{self.class.name}##{attribute_name} expected item class: #{expected_class} got: #{klass}"
        end
      end
    end

    def assert_array_types(name, allowed_classes)
      assert_attribute_type(name, Array)

      __send__(name).each do |value|
        klass = value.class

        unless allowed_classes.include?(klass)
          fail TypeError, "#{self.class.name}##{name} allowed item classes: #{allowed_classes.join(', ')} got: #{klass}"
        end
      end
    end
  end # TypeCheck
end # MCake
