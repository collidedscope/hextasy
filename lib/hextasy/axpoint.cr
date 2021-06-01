require "hextasy/heading"

record Hextasy::Axpoint, q : Int32, r : Int32 do
  def self.origin
    new 0, 0
  end

  def +(other)
    Axpoint.new @q + other.q, @r + other.r
  end

  def +(q, r)
    Axpoint.new @q + q, @r + r
  end

  def -(other)
    Axpoint.new @q - other.q, @r - other.r
  end

  def -(q, r)
    Axpoint.new @q - q, @r - r
  end

  def *(v)
    Axpoint.new @q * v, @r * v
  end

  def s
    -q - r
  end

  def cube
    {q, s, r}
  end

  def -(heading)
    self + heading.reverse
  end

  def neg
    Axpoint.new -q, -r
  end

  def rotate
    Axpoint.new -r, -s
  end

  def tuple
    {q, r}
  end

  def distance(other)
    {q - other.q, r - other.r, s - other.s}.sum &.abs / 2
  end

  def distance_from_origin
    distance Axpoint.origin
  end

  def +(heading)
    {% begin %}
      case heading
        {% for heading, vector in HEADINGS %}
          when .{{heading}}?; {{heading}}
        {% end %}
      end.not_nil!
    {% end %}
  end

  {% for heading, vector in HEADINGS %}
    def {{heading}}(n = 1)
      self.+ *{{vector}}.map { |offset| offset * n }
    end
  {% end %}
end
