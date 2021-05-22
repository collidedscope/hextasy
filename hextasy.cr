require "hextasy"

source = if path = ARGV[0]?
           File.read path
         else
           STDIN.gets_to_end
         end

Hextasy::Hexagony.new(source).interpret
