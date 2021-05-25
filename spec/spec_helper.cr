require "hextasy"
require "spec"

def example(name)
  File.read "#{__DIR__}/../examples/#{name}.hxg"
end

class Hextasy::Hexagony
  def run_on(input)
    # TODO: Don't do this once/if `IO::Memory#peek` returns a writeable buffer.
    i = IO::Memory.new String.build &.<< input
    o = IO::Memory.new 32

    interpret i, o
    o.to_s
  end
end
