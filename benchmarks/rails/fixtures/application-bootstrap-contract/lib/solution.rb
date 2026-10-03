# frozen_string_literal: true

class RailsApplicationBootstrap
  def initialize(help_output:)
    @help_output = help_output
  end

  def command(_app_name, **_options)
    nil
  end

  def option_supported?(_option)
    false
  end
end
