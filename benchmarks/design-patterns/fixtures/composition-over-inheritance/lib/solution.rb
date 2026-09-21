CsvFormatter = Struct.new(:prefix) do
  def render(data)
    "csv: #{data}"
  end
end

PdfFormatter = Struct.new(:prefix) do
  def render(data)
    "pdf: #{data}"
  end
end

class Report
  def initialize(formatter:)
    @formatter = formatter
  end

  def render(data)
    @formatter.render(data)
  end
end
