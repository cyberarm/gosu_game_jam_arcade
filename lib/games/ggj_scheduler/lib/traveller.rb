class SchedulerGame
  class Traveller
    TRAVELLER_SIZE = Path::PATH_SIZE - 4
    TRAVELLER_COLOR = Gosu::Color::BLACK

    attr_reader :map, :zone, :goal, :path, :path_index

    def initialize(map:, zone:, goal:)
      @map = map
      @zone = zone
      @goal = goal

      @path = nil
      @path_index = 0

      @counter = 0.0
      @node_visit_time = 200
    end

    def path=(path)
      @counter = 0
      @path_index = 0

      @pathed = true

      @path = path
    end

    def draw
      node = get_node

      Gosu.draw_rect(
        node.position.x * Map::TILE_SIZE + (TRAVELLER_SIZE / 2),
        node.position.y * Map::TILE_SIZE + (TRAVELLER_SIZE / 2),
        TRAVELLER_SIZE,
        TRAVELLER_SIZE,
        TRAVELLER_COLOR,
        200
      )

      Gosu.draw_circle(
        node.position.x * Map::TILE_SIZE + TRAVELLER_SIZE,
        node.position.y * Map::TILE_SIZE + TRAVELLER_SIZE,
        TRAVELLER_SIZE * 0.25,
        5,
        Gosu::Color::WHITE,
        200
      )
    end

    def update(dt = 20)
      move_along_path(dt) if @path
    end

    def get_node
      @path ? @path.nodes[@path_index] : zone_node_slot
    end

    def zone_node_slot
      @pathed ? @zone.nodes.detect { |n| n.data[:traveller] == self } : @zone.nodes.first
    end

    def move_along_path(dt)
      @counter += dt

      data = @path.nodes[@path_index].data

      if @counter >= @node_visit_time
        @counter = 0

        if @path_index == @path.nodes.size - 1
          @zone = path_zone_for(@path.nodes.last)
          data[:traveller] = nil

          free_node = @zone.nodes.detect { |n| n.data[:traveller].nil? }
          free_node.data[:traveller] = self

          @goal = nil
          @path = nil

          return
        end

        data[:traveller] = nil

        @path_index += 1
        @path_index = @path.nodes.size - 1 if @path_index >= @path.nodes.size - 1

        next_data = @path.nodes[@path_index].data

        if next_data[:traveller].nil?
          next_data[:traveller] = self
        else
          @path_index -= 1
        end
      end
    end

    def path_zone_for(node)
      return false unless node

      # UP
      up = @map.get_zone(node.position.x, node.position.y - 1)
      return up if up

      # DOWN
      down = @map.get_zone(node.position.x, node.position.y + 1)
      return down if down

      # LEFT
      left = @map.get_zone(node.position.x - 1, node.position.y)
      return left if left

      # RIGHT
      right = @map.get_zone(node.position.x + 1, node.position.y)
      return right if right

      false
    end
  end
end
