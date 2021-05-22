struct Hextasy::Axpoint
  HEADINGS = {
    northwest: {0, -1},
    northeast: {+1, -1},
    east:      {+1, 0},
    southeast: {0, +1},
    southwest: {-1, +1},
    west:      {-1, 0},
  }

  enum Heading
    {% for heading, vector in HEADINGS %}
      {{heading.capitalize.id}}
    {% end %}

    def reverse
      case self
      when .northwest?; Southeast
      when .northeast?; Southwest
      when .east?     ; West
      when .southeast?; Northwest
      when .southwest?; Northeast
      else              East
      end
    end

    def slash
      case self
      when .northwest?; East
      when .northeast?; Northeast
      when .east?     ; Northwest
      when .southeast?; West
      when .southwest?; Southwest
      else              Southeast
      end
    end

    def backslash
      case self
      when .northwest?; Northwest
      when .northeast?; West
      when .east?     ; Southwest
      when .southeast?; Southeast
      when .southwest?; East
      else              Northeast
      end
    end

    def lt(edge)
      case self
      when .northwest?; West
      when .northeast?; Southwest
      when .east?     ; edge > 0 ? Southeast : Northeast
      when .southeast?; Northwest
      when .southwest?; West
      else              East
      end
    end

    def gt(edge)
      case self
      when .northwest?; Southeast
      when .northeast?; East
      when .east?     ; West
      when .southeast?; East
      when .southwest?; Northeast
      else              edge > 0 ? Northwest : Southwest
      end
    end

    def underscore
      case self
      when .northwest?; Southwest
      when .northeast?; Southeast
      when .east?     ; East
      when .southeast?; Northeast
      when .southwest?; Northwest
      else              West
      end
    end

    def pipe
      case self
      when .northwest?; Northeast
      when .northeast?; Northwest
      when .east?     ; West
      when .southeast?; Southwest
      when .southwest?; Southeast
      else              East
      end
    end
  end
end
