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

  def turn_left!
    # @right += Axpoint::Heading.from_value @direction.value.succ % 6
    case direction
    when .north?    ; @right = @left.northeast
    when .northwest?; @right = @left.northwest
    when .southwest?; @right = @left.west
    when .south?    ; @right = @left.southwest
    when .southeast?; @right = @left.southeast
    when .northeast?; @right = @left.east
    end
    @direction = @direction.anticlockwise
    self
  end

  def turn_right!
    # @left += Axpoint::Heading.from_value @direction.value
    case direction
    when .north?    ; @left = @right.northwest
    when .northeast?; @left = @right.northeast
    when .southeast?; @left = @right.east
    when .south?    ; @left = @right.southeast
    when .southwest?; @left = @right.southwest
    when .northwest?; @left = @right.west
    end
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
