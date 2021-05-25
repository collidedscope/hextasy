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
  @debug = Set(Axpoint).new

  def initialize(source)
    flags = source.count '`'
    insns = source.delete(" \f\n\r\t\v").chars
    @size = Util.hex_size insns.size - flags
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
      row_lengths[i].times do
        if (insn = insns.shift?) == '`'
          @debug << cell
          insn = insns.shift?
        end

        @program[cell] = insn || '.'
        cell = cell.east
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

  macro getnum
    while b = input.read_byte
      break if b.chr.in_set? "0-9+-"
    end
    return 0 unless b

    peek = input.peek
    len = peek.take_while { |c| 48 <= c <= 57 }.size
    input.read buffer = peek[0, len]

    return 0 if b < 48 && buffer.empty?
    "#{b.chr}#{String.new buffer}"
  end

  def reset
    memory.clear
    @active_ip = 0
    @instruction_pointers = StaticArray(InstructionPointer, 6).new { |i|
      heading = Axpoint::Heading.from_value (i + 2) % 6
      InstructionPointer.new corners[i], heading, self
    }
  end

  def interpret(input = STDIN, output = STDOUT)
    clock = 0
    insn = '.'
    reset

    loop do
      step

      if @debug.includes? ip.cell
        STDERR.puts "\nTick #{clock}: '#{insn}'", memory
      end

      clock += 1
      ip.tick!

      @active_ip = case insn
                   when '[' ; @active_ip.pred % 6
                   when ']' ; @active_ip.succ % 6
                   when '#' ; memget.to_i % 6
                   else       @active_ip
                   end
    end
  end

  macro step
    case insn = @program[ip.cell]
      # no-op
    when '.'
      # halt
    when '@' ; break
      # mirrors
    when '/' ; ip.heading = ip.heading.slash
    when '\\'; ip.heading = ip.heading.backslash
    when '_' ; ip.heading = ip.heading.underscore
    when '|' ; ip.heading = ip.heading.pipe
      # reflect or branch
    when '<' ; ip.heading = ip.heading.lt memget
    when '>' ; ip.heading = ip.heading.gt memget
      # skip
    when '$' ; ip.tick!
      # get byte
    when ',' ; memset (input.read_byte || -1).to_i64
      # get integer
    when '?' ; memset getnum.to_i64
      # put byte
    when ';' ; output.write_byte (memget & 0xFF).to_u8
      # put integer
    when '!' ; output << memget
      # decrement
    when '(' ; memset memget - 1
      # increment
    when ')' ; memset memget + 1
      # negate
    when '~' ; memset -memget
      # add/sub/mul/div
    when '+' ; binop :+
    when '-' ; binop :-
    when '*' ; binop :*
    when ':' ; memset left // right
      # memory pointer navigation
    when '=' ; memory_pointer.reverse!
    when '{' ; memory_pointer.turn_left!
    when '}' ; memory_pointer.turn_right!
    when 39  ; memory_pointer.reverse!.turn_left!.reverse! # '\'' breaks macro parsing
    when '"' ; memory_pointer.reverse!.turn_right!.reverse!
    when '^' ; memget > 0 ? memory_pointer.turn_right! : memory_pointer.turn_left!
      # copy
    when '&' ; memset memget > 0 ? right : left
      # modulus
    when '%'
      left, right = neighbors
      mod = case {left, right}
            when {Int64, Int64}
              left % right
            else
              left.to_big_i % right
            end
      memset mod
      # alphabetic literals
    when 'A'..'Z', 'a'..'z'
      memset insn.ord.to_i64
      # numeric literals
    when '0'..'9'
      val = insn - '0'
      mag = checked_binop memget, :*, 10
      val *= -1 if mag < 0
      memset checked_binop mag, :+, val
    end
  end
end
