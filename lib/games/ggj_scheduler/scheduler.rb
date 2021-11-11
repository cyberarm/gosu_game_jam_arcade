require "cyberarm_engine"

GAME_ROOT_PATH = File.expand_path(".", __dir__)

require_relative "lib/window"
require_relative "lib/map"
require_relative "lib/node"
require_relative "lib/path"
require_relative "lib/zone"
require_relative "lib/traveller"
require_relative "lib/states/main_menu"
require_relative "lib/states/game"
require_relative "lib/states/game_won"
require_relative "lib/states/game_lost"
require_relative "lib/states/pause"
