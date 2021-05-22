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
    {% for heading in HEADINGS.keys %}
      {{heading.capitalize.id}}
    {% end %}

    def lt(edge)
      east? ? (edge > 0 ? Southeast : Northeast) : ltprime
    end

    def gt(edge)
      west? ? (edge > 0 ? Northwest : Southwest) : gtprime
    end
  end

  EXPAND = {NW: Northwest, NE: Northeast, E: East,
            SE: Southeast, SW: Southwest, W: West}

  macro def_mirror(name, mapping)
    {% begin %}
      enum Heading
        def {{name}}
          case self
            {% for pair in mapping.split %}
              in {{EXPAND[pair.split("->")[0]]}}
                 {{EXPAND[pair.split("->")[1]]}}
            {% end %}
          end
        end
      end
    {% end %}
  end

  def_mirror reverse,    "NW->SE  NE->SW  E->W   SE->NW  SW->NE  W->E"
  def_mirror slash,      "NW->E   NE->NE  E->NW  SE->W   SW->SW  W->SE"
  def_mirror backslash,  "NW->NW  NE->W   E->SW  SE->SE  SW->E   W->NE"
  def_mirror underscore, "NW->SW  NE->SE  E->E   SE->NE  SW->NW  W->W"
  def_mirror pipe,       "NW->NE  NE->NW  E->W   SE->SW  SW->SE  W->E"
  def_mirror ltprime,    "NW->W   NE->SW  E->E   SE->NW  SW->W   W->E"
  def_mirror gtprime,    "NW->SE  NE->E   E->W   SE->E   SW->NE  W->W"
end
