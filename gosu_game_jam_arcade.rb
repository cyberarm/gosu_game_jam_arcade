require "gosu"

module Gosu
  Permafrost = Window
end

class GosuGameJamArcade
  GAME_ROOT_PATH = File.expand_path(".", __dir__)
end

Gosu.send(:remove_const, :Window)

require_relative "lib/permafrost"
require "cyberarm_engine"

require_relative "lib/window"
require_relative "lib/interface/window"
require_relative "lib/interface/menu"

# LOAD GAMES
require_relative "lib/games/pet-peeve/src/main"
require_relative "lib/games/boxes/init"
require_relative "lib/games/relax/start_game"
require_relative "lib/games/chaos_penguin/main"
require_relative "lib/games/ggj_scheduler/scheduler"

GosuGameJamArcade::Window.new.show