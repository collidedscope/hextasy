require "big"

class Hextasy::Hexagony
  alias MemoryEdge = Array(Tuple(Int32, Int32))

  getter size : Int32
  getter corners : Array(Axpoint)
  getter memory = Hash(MemoryEdge, Int64 | BigInt).new 0i64
  getter memory_pointer = MemoryPointer.new
  getter! instruction_pointers

  @active_ip = 0
  @program = {} of Axpoint => Char

  def initialize(source)
    insns = source.delete(" \f\n\r\t\v").chars
    @size = Util.hex_size insns.size
    @corners = Axpoint::HEADINGS.map { |heading, vector|
      Axpoint.new *vector.map &.*(@size - 1)
    }

    row_starts = [cell = @corners[0]]
    (1...@size).each { |i| row_starts << cell.southwest i }
    middle = row_starts.last
    (1...@size).each { |i| row_starts << middle.southeast i }

    parse! insns, row_starts
  end

  def parse!(insns, row_starts)
    row_lengths = Util.rows @size

    row_starts.each_with_index do |cell, i|
      row_lengths[i].times do |offset|
        @program[cell.east offset] = insns.shift? || '.'
      end
    end
  end

  macro ip
    instruction_pointers[@active_ip]
  end

  macro memget
    memory[memory_pointer.edge]
  end

  macro memset(value)
    memory[memory_pointer.edge] = {{value}}
  end

  macro left
    memory[memory_pointer.dup.tap(&.turn_left!).edge]
  end

  macro right
    memory[memory_pointer.dup.tap(&.turn_right!).edge]
  end

  macro neighbors
    {left, right}
  end

  macro checked_binop(left, op, right)
    begin
      {{left}} {{op.id}} {{right}}
    rescue OverflowError
      {{left}}.to_big_i {{op.id}} {{right}}
    end
  end

  macro binop(op)
    memset checked_binop left, {{op}}, right
  end

  def interpret(io = STDOUT)
    @instruction_pointers = StaticArray(InstructionPointer, 6).new { |i|
      heading = Axpoint::Heading.from_value (i + 2) % 6
      InstructionPointer.new corners[i], heading, self
    }

    loop do
      case insn = @program[ip.cell]
      when '.' # do nothing
      when '@' ; break
      when '/' ; ip.heading = ip.heading.slash
      when '\\'; ip.heading = ip.heading.backslash
      when '<' ; ip.heading = ip.heading.lt memget
      when '>' ; ip.heading = ip.heading.gt memget
      when '_' ; ip.heading = ip.heading.underscore
      when '|' ; ip.heading = ip.heading.pipe
      when '$' ; ip.tick!
      when ',' ; memset (io.read_byte || -1).to_i64
      when ';' ; io.write_byte (memget & 0xFF).to_u8
      when '!' ; io << memget
      when '(' ; memset memget - 1
      when ')' ; memset memget + 1
      when '~' ; memset -memget
      when '+' ; binop :+
      when '-' ; binop :-
      when '*' ; binop :*
      when ':' ; memset left // right
      when '=' ; memory_pointer.reverse!
      when '{' ; memory_pointer.turn_left!
      when '}' ; memory_pointer.turn_right!
      when '\''; memory_pointer.reverse!.turn_left!.reverse!
      when '"' ; memory_pointer.reverse!.turn_right!.reverse!
      when '[' ; @active_ip = @active_ip.pred % 6
      when ']' ; @active_ip = @active_ip.succ % 6
      when '#' ; @active_ip = memget.to_i % 6
      when '%'
        left, right = neighbors
        mod = case {left, right}
              when {Int64, Int64}
                left % right
              else
                left.to_big_i % right
              end
        memset mod
      when 'A'..'Z', 'a'..'z'
        memset insn.ord.to_i64
      when '0'..'9'
        val = insn - '0'
        mag = checked_binop memget, :*, 10
        val *= -1 if mag < 0
        memset checked_binop mag, :+, val
      else
        abort "'#{insn}' not yet implemented!"
      end

      ip.tick!
    end
  end
end
