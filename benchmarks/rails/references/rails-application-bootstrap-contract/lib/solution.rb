# frozen_string_literal: true

class RailsApplicationBootstrap
  def initialize(help_output:)
    @help_output = help_output
  end

  def command(app_name, api_only: false, database: nil, javascript: nil, css: nil, skip: [], template: nil, force: false)
    raise ArgumentError, "force requires explicit override" if force

    args = ["rails", "new", app_name]
    args << "--api" if api_only
    args << "--database=#{database}" if database
    args << "--javascript=#{javascript}" if javascript
    args << "--css=#{css}" if css

    skip.each do |option|
      args << option if option_supported?(option)
    end

    args.concat(["-m", template]) if template
    args.join(" ")
  end

  def option_supported?(option)
    @help_output.include?(option)
  end
end
