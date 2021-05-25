class Hextasy::InstructionPointer
  property \
    cell : Axpoint,
    heading : Axpoint::Heading,
    program : Hexagony
  property? cornered = false

  def initialize(@cell, @heading, @program)
  end

  def tick!
    @cornered = if corner = program.corners.index @cell
                  heading.value == corner
                end
    @cell += @heading
    wrap! if @cell.distance_from_origin >= program.size
  end

  def wrap!
    if cornered?
      mem = program.memory[program.memory_pointer.edge]
      new = heading.value + mem.pred.sign * 2
      @cell = program.corners[new % 6]
      return
    end

    x, y, z = @cell.cube.map { |c| c.abs >= program.size }

    @cell -= heading
    coords = if !x && !y
               {cell.r + cell.q, -cell.r}
             elsif !y && !z
               {-cell.q, cell.r + cell.q}
             else
               {-cell.r, -cell.q}
             end
    @cell = Axpoint.new *coords
  end
end
