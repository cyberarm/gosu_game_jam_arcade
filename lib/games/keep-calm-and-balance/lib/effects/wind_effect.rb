class KeepCalmAndBalanceGame
  WEST = 'west' # blowing to the right
  EAST = 'east' # blowing to the left

  class WindEffect
    attr_reader :name

    def initialize(infopane, seasaw, barrel)
      @infopane = infopane
      @seasaw = seasaw # not utilized
      @barrel = barrel

      @direction = [WEST, EAST].sample
      @name = "#{@direction} wind"
    end

    def update
      @strength = rand(5)
      @speed = {WEST => 1, EAST => -1}[@direction] * @strength * ACCELERATION

      @barrel.speed = (@barrel.speed + @speed).round(SPEED_PRECISION)
    end

    def draw
      # TODO nothing?
    end
  end
end