Report = Struct.new(:header, :sections, keyword_init: true)

class ReportBuilder
  def initialize
    @header = nil
    @sections = []
  end

  def add_header(text)
    @header = text
    self
  end

  def add_section(text)
    @sections << text
    self
  end

  def build
    Report.new(header: @header, sections: @sections.dup.freeze)
  end
end
