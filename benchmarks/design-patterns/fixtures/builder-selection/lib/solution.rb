Report = Struct.new(:header, :sections, keyword_init: true)

class ReportBuilder
  def initialize
    @header = nil
    @sections = []
  end

  def add_header(text)
    raise NotImplementedError
  end

  def add_section(text)
    raise NotImplementedError
  end

  def build
    raise NotImplementedError
  end
end
