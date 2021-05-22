require "hextasy"
require "option_parser"

OptionParser.parse do |parser|
  parser.banner = <<-EOS
  Hextasy is a Hexagony interpreter.
  Usage: #{PROGRAM_NAME} [OPTIONS] FILE
  EOS

  parser.on("-h", "--help", "Show this help") {
    abort parser
  }

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    abort parser
  end
end

source = if path = ARGV[0]?
           File.read path
         else
           STDIN.gets_to_end
         end

Hextasy::Hexagony.new(source).interpret
