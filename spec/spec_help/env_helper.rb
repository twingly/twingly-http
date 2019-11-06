# frozen_string_literal: true

require "climate_control"

module EnvHelper
  module_function

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
