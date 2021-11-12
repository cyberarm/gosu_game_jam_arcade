require_relative './paddle_effect'
require_relative './wind_effect'

class KeepCalmAndBalanceGame
  FIRST_EFFECT_TIME = 2 # seconds til the first effect
  NEXT_EFFECT_TIME = 3 # seconds til the next effect
  SHOW_LATEST_TIME = 1.0 # seconds to show the latest effect for (float needed!)

  class EffectDealer
    #attr_reader :active # TODO nothing?

    def initialize(infopane, seasaw, barrel)
      @infopane = infopane
      @seasaw = seasaw
      @barrel = barrel

      @other_known = [PaddleEffect] # added to available later
      reset!
    end

    # Load default setup
    def reset!
      @available = [WindEffect]
      @active = []
      @latest = nil
      @latest_at = nil
      @next_at = FIRST_EFFECT_TIME
    end

    def update
      @active.each { |ee| ee.update }

      if time_for_next?
        @latest = @available.sample.new(@infopane, @seasaw, @barrel) # pick random one
        @active.push(@latest)

        if !@latest_at # the first effect just got picked
          @available += @other_known
        end

        @latest_at = @infopane.time
      end
    end

    def draw
      @active.each { |ee| ee.draw }
      draw_latest
      draw_counter
    end

    def draw_latest
      if @latest and @infopane.time < (@latest_at + SHOW_LATEST_TIME)
        latest = Gosu::Image.from_text(
          "+#{@latest.name.capitalize}", LINE_HEIGHT,
          {:width => WINDOW_WIDTH, :align => :left}
        )
        latest.draw(0, 0, ZTEXT)
      end
    end

    def draw_counter
      counter_text = ""
      counts_of_effects.each { | kk, vv | counter_text += "#{vv}x #{kk.capitalize}\n"}

      counter = Gosu::Image.from_text(
        counter_text, LINE_HEIGHT,
        {:width => WINDOW_WIDTH, :align => :right}
      )
      counter.draw(0, 0, ZTEXT)
    end

    # Return count of each active variant of effect, sorted alphabetically
    def counts_of_effects
      counts = {}

      @active.each { |ee|
        if counts[ee.name]
          counts[ee.name] += 1
        else
          counts[ee.name] = 1
        end
      }

      return counts.sort.to_h
    end

    # Is it time to activate the next effect?
    def time_for_next?
      if @infopane.time > @next_at # equality is not safe enough as update() can just miss the mark
        @next_at += NEXT_EFFECT_TIME
        return true
      else
        return false
      end
    end
  end
end