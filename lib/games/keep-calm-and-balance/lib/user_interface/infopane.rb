class KeepCalmAndBalanceGame
  class Infopane
    attr_reader :time

    def initialize(window)
      @window = window
      reset!
    end

    # Load default setup
    def reset!
      @starttime = Gosu.milliseconds
      @time = 0
    end

    def update()
      unless @window.loss
        @time = (Gosu.milliseconds - @starttime) / 1000.0
      end
    end

    def draw
      text = "#{@time}s"

      if @window.loss
        text += "\nBackspace to restart"
      end

      text = Gosu::Image.from_text(
        text, LINE_HEIGHT,
        {:width => WINDOW_WIDTH, :align => :center}
      )
      text.draw(0, 0, ZTEXT)
    end
  end
end