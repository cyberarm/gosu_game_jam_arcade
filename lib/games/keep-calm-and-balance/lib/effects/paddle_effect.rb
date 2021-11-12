class KeepCalmAndBalanceGame
  PADDLE_LIMITED = 60
  PADDLE_CHANGE = 0.003 # percentage

  LONG = 'long' # longer seasaw
  SHORT = 'short' # longer seasaw
  THICK = 'thick' # thicker seasaw
  THIN = 'small' # thiner seasaw

  class PaddleEffect
    attr_reader :name

    def initialize(infopane, seasaw, barrel)
      @infopane = infopane
      @seasaw = seasaw # not utilized
      @barrel = barrel

      @type = [LONG, SHORT, THICK, THIN].sample
      @name = "#{@type} paddle"

      @times_applied = 0
    end

    def update
      if @times_applied < PADDLE_LIMITED
        @direction = {
          LONG => 1,
          SHORT => -1,
          THICK => 1,
          THIN => -1
        }[@type]
        coeficient = 1 + @direction * PADDLE_CHANGE # add or sub the change

        case @type
        when LONG, SHORT then
          @seasaw.scale_x *= coeficient
        when THICK, THIN then
          @seasaw.scale_y *= coeficient
        end

        @times_applied += 1
      end
    end

    def draw
      # TODO nothing?
    end
  end
end