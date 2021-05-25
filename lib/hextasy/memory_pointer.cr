class Hextasy::MemoryPointer
  enum Direction
    North
    Northeast
    Southeast
    South
    Southwest
    Northwest

    def clockwise
      self.class.from_value value.succ % 6
    end

    def anticlockwise
      self.class.from_value value.pred % 6
    end

    def reverse
      self.class.from_value (value + 3) % 6
    end
  end

  getter left, right : Axpoint
  property direction : Direction

  def initialize(@left, @right, @direction)
  end

  def initialize
    @left, @right = Axpoint.origin, Axpoint.origin.east
    @direction = Direction::North
  end

  def left!
    @right = left + Axpoint::Heading.from_value direction.value.succ % 6
    @direction = @direction.anticlockwise
    self
  end

  def right!
    @left = right + Axpoint::Heading.from_value direction.value
    @direction = @direction.clockwise
    self
  end

  def reverse!
    @left, @right = right, left
    @direction = @direction.reverse
    self
  end

  def edge
    [@left.tuple, @right.tuple].sort
  end
end
