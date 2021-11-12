# Encoding: UTF-8
#                                             #
#                Relax.                       #
#            You've earned it.                #
#                                             #
#                                             #

# require "gosu"
require_relative 'chingu/chingu'
require_relative "rb/intro_objects.rb"
require_relative "rb/beginning.rb"
require_relative "rb/living_room.rb"
require_relative "rb/player"
require_relative "rb/human"
require_relative "rb/units"
require_relative "rb/toy_chest"
require_relative "rb/map"
require_relative "rb/particles"
require_relative "rb/level_1"
require_relative "rb/level_2"
require_relative "rb/level_3"
require_relative "rb/level_4"
require_relative "rb/level_5"
require_relative "rb/ending"


class RelaxGame
  GAME_ROOT_PATH = File.expand_path(".", __dir__)

  module Z   # zorder constants
    BACKGROUND = 0; STARS = 1; UNIT = 2;
    PLAYER = 3; UI = 4; GUI = 400; Text = 300;
    Object = 50; Projectile = 15; Particle = 5;
    Main_Character_Particles = 199;
    Main_Character = 200
  end

  module Colors   # colors
    Dark_Orange = Gosu::Color.new(0xFFCC3300)
    White = Gosu::Color.new(0xFFFFFFFF)
    Black = Gosu::Color::BLACK
    Blue_Laser = Gosu::Color.new(0xFF86EFFF)
  end

  class Game < Chingu::Window
    # trait :debug => true

    def initialize
      super(1100,700,false) #640, 480
      self.caption = "          ______ Relax ______"
      self.input = { :esc => :close,  # global controls
  #                   :p => Pause,
  #                 [:q, :l] => :pop,
  #                 :z => :log,
  #                 :r => lambda{current_game_state.setup}
                    :t => :begin,
                    :y => :ending
                }
  #    retrofy
    end

    def setup
      push_game_state(Beginning)
    end

    def begin
      push_game_state(Introduction)
    end

    def ending
      push_game_state(Ending)
    end


  end
end