require 'csv'

class CSVImportSchema
  attr_reader :columns
  Column = Struct.new(:name, :col_number, :type)

  def initialize
    @columns = []
  end

  def string(name, column:)
    @columns << Column.new(name, column, ->(x) { x.to_s })
  end

  def integer(name, column:)
    @columns << Column.new(name, column, ->(x) { x.to_i })
  end

  def decimal(name, column:)
    @columns << Column.new(name, column, ->(x) { x.to_f })
  end
end

class CSVImport
  attr_reader :schema

  def initialize
    @schema = CSVImportSchema.new
  end

  # define the method in a more explicit form:
  # def self.from_file(filepath, &block)
  #   schema = CSVImportSchema.new()
  #   block.call(schema)
  # end
  def self.from_file(filepath)
    import = new
    yield import.schema
    rows = CSV.read(filepath, col_sep: ';')
    import.process(rows)
  end
  
  def process(rows)
    rows.map { |row| process_row(row) }
  end

  private

  def process_row(row)
    obj = {}
    @schema.columns.each do |col|
      obj[col.name] = col.type.call(row[col.col_number - 1])
    end
    obj
  end
end

records = CSVImport.from_file('people.csv') do |config|
  config.string :first_name, column: 1
  config.string :last_name, column: 2
  config.integer :age, column: 3
  config.decimal :salary, column: 4
end

puts records