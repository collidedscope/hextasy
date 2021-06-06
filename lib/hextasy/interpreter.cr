require "big"

class Hextasy::Hexagony
  alias MemoryEdge = Array(Tuple(Int32, Int32))

  getter \
    insn = '.',
    size : Int32,
    corners : Array(Axpoint),
    memory_pointer = MemoryPointer.new,
    memory = Hash(MemoryEdge, Int64 | BigInt).new 0i64
  getter! instruction_pointers

  @active_ip = 0
  @program = {} of Axpoint => Char
  @row_col = {} of Axpoint => Tuple(Int32, Int32)
  @debug = Set(Axpoint).new
  @clock = 0
  @histogram = Hash(Char, UInt32).new 0u64

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
      offset = (i - @size + 1).abs
      row_lengths[i].times do |j|
        if (insn = insns.shift?) == '`'
          @debug << cell
          insn = insns.shift?
        end

        @program[cell] = insn || '.'
        @row_col[cell] = {i, j * 2 + offset}
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
    memory[memory_pointer.dup.tap(&.left!).edge]
  end

  macro right
    memory[memory_pointer.dup.tap(&.right!).edge]
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

    return 0 unless peek = b && input.peek

    len = peek.take_while { |c| 48 <= c <= 57 }.size
    input.read buffer = peek[0, len]

    b < 48 && buffer.empty? ? 0 : "#{b.chr}#{String.new buffer}"
  end

  def reset
    memory.clear
    @active_ip = 0
    @instruction_pointers = StaticArray(InstructionPointer, 6).new { |i|
      heading = Axpoint::Heading.from_value (i + 2) % 6
      InstructionPointer.new corners[i], heading, self
    }
  end

  def interpret(input = STDIN, output = STDOUT, listener : Channel(Hexagony)? = nil)
    reset

    loop do
      step
      listener && listener.send self
      @histogram[insn] += 1
      break if insn == '@'

      if @debug.includes? ip.cell
        STDERR.puts "\nTick #{@clock}: '#{insn}'", memory
      end

      @clock += 1
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
    case @insn = @program[ip.cell]
      # no-ops
    when '.', '@'
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
    when '{' ; memory_pointer.left!
    when '}' ; memory_pointer.right!
    when 39  ; memory_pointer.reverse!.left!.reverse! # '\'' breaks macro parsing
    when '"' ; memory_pointer.reverse!.right!.reverse!
    when '^' ; memget > 0 ? memory_pointer.right! : memory_pointer.left!
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
      # numeric literals
    when '0'..'9'
      val = insn - '0'
      mag = checked_binop memget, :*, 10
      val *= -1 if mag < 0
      memset checked_binop mag, :+, val
      # active IP manipulation (handled elsewhere)
    when '[', ']', '#'
      # alphabetic literals (and all other codepoints)
    else
      memset insn.ord.to_i64
    end
  end

  def report
    puts "\nInstruction histogram:"
    @histogram.to_a.sort_by(&.last).reverse_each do |insn, freq|
      puts "\t#{insn} #{freq}"
    end
    puts "\tTotal: #{@histogram.values.sum}"

    puts "Memory edges used: #{memory.size}"
  end
end
