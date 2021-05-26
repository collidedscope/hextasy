require "hextasy"
require "option_parser"

input = STDIN
grid = nil
pretty = nil

OptionParser.parse do |parser|
  parser.banner = <<-EOS
  Hextasy is a Hexagony interpreter.
  Usage: #{PROGRAM_NAME} [OPTIONS] [FILE]
  EOS

  parser.on("-i STR", "--input STR",
    "Input for the read instructions (when stdin isn't suitable)") { |s|
    input = IO::Memory.new s
  }

  parser.on("-g N", "--grid N",
    "Display an empty hexagonal grid of radius N and exit") { |n|
    grid = n.to_i
  }

  parser.on("-p", "--pretty",
    "Pretty-print the program rather than executing it") { pretty = true }

  parser.on("-h", "--help", "Show this help") { abort parser }

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

source = ARGF.gets_to_end
h = Hextasy::Hexagony.new source

if pretty
  puts h.lines
else
  h.interpret input
end
