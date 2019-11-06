# frozen_string_literal: true

class NullLogger
  # rubocop:disable Style/MethodMissingSuper
  def method_missing(method_name, *_args, &_block)
    raise NoMethodError unless respond_to_missing?(method_name)
  end
  # rubocop:enable all

  def respond_to_missing?(method_name, _include_all = false)
    ::Logger.instance_methods.include?(method_name)
  end
end
