module Hextasy::Util
  extend self

  def hex_size(length)
    (((12 * length - 3) ** 0.5 + 3) / 6).ceil.to_i
  end

  def rows(size)
    top = (size...size * 2).to_a
    top.concat top.reverse[1..]
  end
end
