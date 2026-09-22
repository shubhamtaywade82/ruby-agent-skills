# frozen_string_literal: true

class RouteSet
  def initialize
    @routes = []
  end

  def get(path, name:, target:, host: nil, constraint: nil)
    @routes << { path: path, name: name, target: target, host: host, constraint: constraint }
  end

  def recognize(path, host: nil)
    candidates = @routes.select do |route|
      (route[:host].nil? || route[:host] == host) &&
        (route[:constraint].nil? || route[:constraint].call(path)) &&
        match?(route[:path], path)
    end

    candidates.min_by do |route|
      [route[:path].count(":"), route[:path].include?("*") ? 1 : 0, @routes.index(route)]
    end
  end

  def url_for(name, params = {})
    route = @routes.find { |entry| entry[:name] == name }
    raise KeyError, name unless route

    route[:path].gsub(/:([a-z_]+)/) { params.fetch(Regexp.last_match(1).to_sym).to_s }
  end

  private

  def match?(pattern, path)
    return true if pattern == "/*path"
    regex = Regexp.escape(pattern)
      .gsub("\/:id", "/[^/]+")
      .gsub("\/*path", "/.+")
    Regexp.new("\A#{regex}\z").match?(path)
  end
end
