class Report
  def render(data)
    raise NotImplementedError, "subclasses must implement render"
  end
end

class CsvReport < Report
  def render(data)
    "csv: #{data}"
  end
end

class PdfReport < Report
  def render(data)
    "pdf: #{data}"
  end
end
