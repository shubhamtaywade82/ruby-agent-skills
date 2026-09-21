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
  def self.for(format)
    raise NotImplementedError
  end
end
