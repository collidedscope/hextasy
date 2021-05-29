class Hextasy::Hexagony
  def lines
    lines = Util.rows(@size).map { |r|
      Array(Char).new @size * 2 - 2 + r, ' '
    }

    @program.each do |cell, insn|
      row, col = @row_col[cell]
      lines[row][col] = insn
    end

    lines.map(&.join).join '\n'
  end

  def draw
    y, x = @row_col[ip.cell]
    print "\e[#{y+1};#{x+1}H\e[38;5;#{rand 255}m#{@program[ip.cell]}"
  end
end
