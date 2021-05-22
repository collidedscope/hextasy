require "hextasy"
require "option_parser"

grid = nil

OptionParser.parse do |parser|
  parser.banner = <<-EOS
  Hextasy is a Hexagony interpreter.
  Usage: #{PROGRAM_NAME} [OPTIONS] FILE
  EOS

  parser.on("-g N", "--grid N",
    "Display an empty hexagonal grid of radius N and exit") { |n|
    grid = n.to_i
  }

  parser.on("-h", "--help", "Show this help") {
    abort parser
  }

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    abort parser
  end
end

if n = grid
  Hextasy::Util.rows(n).each do |row|
    puts Array.new(row, '.').join(' ').center(n * 4 - 2).rstrip
  end
  exit
end

source = if path = ARGV[0]?
           File.read path
         else
           STDIN.gets_to_end
         end

Hextasy::Hexagony.new(source).interpret
