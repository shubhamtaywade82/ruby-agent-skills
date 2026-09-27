# frozen_string_literal: true

class RouteSet
  def initialize
    @routes = []
  end

  def get(path, name:, target:, host: nil, constraint: nil)
    @routes << { path: path, name: name, target: target, host: host, constraint: constraint, pattern: compile(path) }
  end

  # Literal segments outrank dynamic ones, dynamic outranks the catch-all,
  # then declaration order. A path owned by a declared route is never handed
  # to the catch-all when that route's host/constraint rejects the request.
  def recognize(path, host: nil)
    path_matches = @routes.select { |route| route[:pattern].match?(path) }
    specific, catch_all = path_matches.partition { |route| !route[:path].include?("*") }

    candidates = specific.empty? ? catch_all : specific
    accepted = candidates.select { |route| host_matches?(route, host) && constraint_matches?(route, path) }
    accepted.min_by { |route| [route[:path].count(":"), @routes.index(route)] }
  end

  def url_for(name, params = {})
    route = @routes.find { |entry| entry[:name] == name }
    raise KeyError, "unknown route: #{name}" unless route

    route[:path].gsub(/:([a-z_]+)/) { params.fetch(Regexp.last_match(1).to_sym).to_s }
  end

  private

  def compile(path)
    source = path.split("/", -1).map do |segment|
      if segment.start_with?(":") then "[^/]+"
      elsif segment.start_with?("*") then ".+"
      else Regexp.escape(segment)
      end
    end.join("/")
    Regexp.new("\\A#{source}\\z")
  end

  # Host and custom constraints only select a route; they grant no access.
  def host_matches?(route, host)
    route[:host].nil? || route[:host] == host
  end

  def constraint_matches?(route, path)
    route[:constraint].nil? || route[:constraint].call(path)
  end
end
