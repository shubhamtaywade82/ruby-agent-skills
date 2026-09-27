class JsonParser
  def parse(input)
    "json: #{input}"
  end
end

class CsvParser
  def parse(input)
    "csv: #{input}"
  end
end

class ParserFactory
  PARSERS = { json: JsonParser, csv: CsvParser }.freeze

  def self.for(format)
    PARSERS.fetch(format) { raise ArgumentError, "unsupported format: #{format}" }.new
  end
end
