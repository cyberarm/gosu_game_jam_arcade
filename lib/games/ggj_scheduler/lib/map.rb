class SchedulerGame
  class Map
    include CyberarmEngine::Common

    TILE_SIZE = 16

    TILE_TYPES = {
      "#" => :wall,
      " " => :floor,
      "F" => :field,
      "P" => :pit,
      "D" => :entry_door,
      "I" => :competition_inlet,
      "O" => :competition_outlet,
      "Q" => :team_queue,
      "A" => :audience,
    }

    TILE_COLORS = {
      floor: 0xdd_111111,
      wall: Gosu::Color::GRAY,
      field: 0xff_aa4400,
      entry_door: Gosu::Color::CYAN,
      pit: Gosu::Color::WHITE,
      audience: Gosu::Color::YELLOW,
      team_queue: Gosu::Color::BLUE,
      competition_inlet: Gosu::Color::RED,
      competition_outlet: Gosu::Color::GREEN,
    }

    attr_reader :zones, :travellers, :paths

    def initialize(file:)
      @file = File.read(file)

      @grid = []
      @zones = []
      @travellers = []

      @paths = []

      @path_navigated = get_sample("#{GAME_ROOT_PATH}/media/sfx/oga_farfadet46_pop.ogg")

      parse
      parse_zones

      entry_door = @zones.find { |zone| zone.type == :entry_door }

      @zones.reject { |z| z.type == :entry_door }.each do |zone|
        zone.capacity.times do
          @travellers << Traveller.new(map: self, zone: entry_door, goal: zone)
        end
      end

      @scaler = [window.width / (@width.to_f * TILE_SIZE), window.height / (@height.to_f * TILE_SIZE)].min
    end

    def parse
      y = 0

      @file.each_line do |line|
        x = 0
        line.strip.chars do |char|
          @grid << Node.new(
            position: CyberarmEngine::Vector.new(x, y, 0),
            type: parse_char(char),
            color: tile_color(parse_char(char))
          )

          x += 1
        end

        y += 1

        @width  = x
        @height = y
      end
    end

    def parse_zones
      nodes.reject { |n| %i[wall floor].include?(n.type) }.each do |node|
        next if node_zoned?(node)

        _nodes = floodfill_select(node, node.type).shuffle

        @zones << Zone.new(map: self, type: node.type, nodes: _nodes)
      end
    end

    def node_zoned?(node)
      @zones.detect { |z| z.nodes.include?(node) }
    end

    def parse_char(char)
      TILE_TYPES[char] || raise("No parser for: #{char.inspect}")
    end

    def tile_color(type)
      TILE_COLORS[type] || raise("No color for: #{type.inspect}")
    end

    def draw
      Gosu.scale(@scaler, @scaler) do
        @height.times do |y|
          Gosu.draw_rect(
            0,
            y * TILE_SIZE,
            @width * TILE_SIZE,
            1,
            Gosu::Color::BLACK
          )

          @width.times do |x|
          Gosu.draw_rect(
            x * TILE_SIZE,
            0,
            1,
            @height * TILE_SIZE,
            Gosu::Color::BLACK
          )

            Gosu.draw_rect(
              x * TILE_SIZE,
              y * TILE_SIZE,
              TILE_SIZE,
              TILE_SIZE,
              get(x, y).color,
              1
            )
          end
        end

        @travellers.each do |traveller|
          traveller.draw
        end

        @zones.each do |zone|
          zone.draw
        end
      end
    end

    def update
      @scaler = [window.width / (@width.to_f * TILE_SIZE), window.height / (@height.to_f * TILE_SIZE)].min

      @zones.each { |z| z.update }
      @travellers.each { |t| t.update }

      purge_paths
    end

    def get(x, y)
      @grid[y * @width + x]
    end

    def set(x, y, value)
      @grid[y * @width + x] = value
    end

    def get_zone(x, y)
      @zones.detect { |z| z.nodes.any? { |n| n.position.x == x && n.position.y == y } }
    end

    def mouse_over(x, y)
      x /= @scaler
      y /= @scaler

      x /= TILE_SIZE
      y /= TILE_SIZE

      get(x.floor.clamp(0..@width - 1), y.floor.clamp(0..@height - 1))
    end

    def nodes
      @grid
    end

    def scaler
      @scaler
    end

    def floodfill_select(node, type, list = [])
      return unless node
      return if list.include?(node)
      return if node.type != type

      list << node

      # UP
      floodfill_select(get(node.position.x, node.position.y - 1), type, list)

      # DOWN
      floodfill_select(get(node.position.x, node.position.y + 1), type, list)

      # LEFT
      floodfill_select(get(node.position.x - 1, node.position.y), type, list)

      # RIGHT
      floodfill_select(get(node.position.x + 1, node.position.y), type, list)

      list
    end

    def purge_paths
      @paths.each do |path|
        next if path.building?

        in_use = @travellers.detect { |t| t.path == path }
        @paths.delete(path) unless in_use
        @path_navigated.play(4.0) unless in_use
      end
    end

    def width
      @width * TILE_SIZE * @scaler
    end

    def height
      @height * TILE_SIZE * @scaler
    end
  end
end
