class Hextasy::Hexagony
  def lines
    lines = Array.new(@size * 2 - 1) {
      Array(Char).new @size * 4 - 3, ' '
    }

    @program.each do |cell, insn|
      row, col = @row_col[cell]
      lines[row][col] = insn
    end

    lines.map(&.join.rstrip).join '\n'
  end
end
