class SchedulerGame
  class Zone
    include CyberarmEngine::Common

    attr_reader :map, :type, :nodes, :mode, :receiving_image, :sending_image

    def initialize(map:, type:, nodes:)
      @map = map
      @type = type
      @nodes = nodes.freeze

      @midpoint = CyberarmEngine::Vector.new(
        @nodes.sum { |n| n.position.x } / @nodes.size.to_f,
        @nodes.sum { |n| n.position.y } / @nodes.size.to_f,
      )

      @mode = @type == :entry_door ? :sending : :receiving

      @receiving_image = window.get_image("#{GAME_ROOT_PATH}/media/receiving.png")
      @sending_image = window.get_image("#{GAME_ROOT_PATH}/media/sending.png")

      @freqency = 100.0
      @random_offset = rand(500.0..5000.0)
    end

    def draw
      case @mode
      when :receiving
        @receiving_image.draw_rot(
          @midpoint.x * Map::TILE_SIZE + Map::TILE_SIZE / 2,
          @midpoint.y * Map::TILE_SIZE - Map::TILE_SIZE / 2 + oscillator,
          250,
          0,
          0.5,
          0.5,
          0.3,
          0.3,
          0xee_ffffff
        )
      when :sending
        @sending_image.draw_rot(
          @midpoint.x * Map::TILE_SIZE + Map::TILE_SIZE / 2,
          @midpoint.y * Map::TILE_SIZE - Map::TILE_SIZE / 2 + oscillator,
          250,
          0,
          0.5,
          0.5,
          0.3,
          0.3,
          0xee_ffffff
        )
      end
    end

    def update
      @mode = nil if capacity == occupancy
      @mode = nil if @type == :entry_door && occupancy.zero?
    end

    def oscillator
      @game_state ||= $window.instance_variable_get(:"@states").find { |s| s.is_a?(States::Game) }

      Math.sin(((@game_state.game_time * 1000.0) + @random_offset) / @freqency) * Map::TILE_SIZE * 0.25
    end

    def capacity
      case @type
      when :pit
        4
      when :field
        9
      when :team_queue
        4
      when :audience
        140
      when :entry_door
        Float::INFINITY
      else
        raise NotImplementedError
      end
    end

    def occupancy
      @map.travellers.select { |t| t.zone == self }.count
    end
  end
end
