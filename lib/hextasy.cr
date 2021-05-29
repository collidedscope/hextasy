module Hextasy
  def self.visualize(h, input, ips)
    print "\e[?1049h"   # save terminal contents
    print "\e[H\e[?25l" # move cursor to top and hide it
    puts h.lines
    print "Output: \e7"

    at_exit do
      STDIN.cooked!
      print "\e[?25h"   # unhide cursor
      print "\e[?1049l" # restore terminal contents
    end

    Signal::INT.trap { exit }
    Signal::TERM.trap { exit }

    output = IO::Memory.new 64
    ch = Channel(Hextasy::Hexagony).new

    spawn do
      loop do
        select
        when h = ch.receive
          h.draw
          STDIN.cooked { print "\e8#{output}" if h.insn == ';' || h.insn == '!' }
          if ips > 0
            sleep 1 / ips
          else
            exit if h.insn == '@' || STDIN.read_byte == 113
          end
        end
      end
    end

    STDIN.raw!
    h.interpret input, output, listener: ch
  end
end

require "hextasy/*"
