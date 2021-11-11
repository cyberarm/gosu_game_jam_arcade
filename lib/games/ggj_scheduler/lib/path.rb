class SchedulerGame
  class Path
    PATH_SIZE = Map::TILE_SIZE - 4

    PATH_COLORS = [
      0xff_1133aa,
      0xff_349f11,
      0xff_32ff91,
      0xff_aa8888
    ]

    @@color_index = 0

    def self.next_color
      @@color_index += 1

      @@color_index % (PATH_COLORS.size - 1)
    end

    attr_reader :map, :valid_types, :nodes
    attr_accessor :externally_valid, :building

    def initialize(map:, color_index:, valid_types: [:floor])
      @map = map
      @color_index = color_index
      @valid_types = valid_types

      @nodes = []

      @externally_valid = true
      @building = true
    end

    def draw
      Gosu.scale(@map.scaler, @map.scaler) do
        @nodes.each do |node|
          Gosu.draw_rect(
            node.position.x * Map::TILE_SIZE + 2,
            node.position.y * Map::TILE_SIZE + 2,
            PATH_SIZE,
            PATH_SIZE,
            valid? ? PATH_COLORS[@color_index % PATH_COLORS.size - 1] : 0xaa_800000,
            2
          )
        end
      end
    end

    def add(x, y)
      node = @map.get(x, y)

      @nodes << node

      @nodes
    end

    def remove(x, y)
      @nodes.delete_if { |node| node.x == x && node.y == y }

      @nodes
    end

    def valid?
      @nodes.select { |node| valid_types.include?(node.type) }.size == @nodes.size && @externally_valid
    end

    def building?
      @building
    end
  end
end
