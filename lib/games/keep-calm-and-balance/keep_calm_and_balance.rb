require 'rubygems'
require 'gosu'

require_relative './lib/user_interface/game_window'


class KeepCalmAndBalanceGame
  GAME_ROOT_PATH = File.expand_path(".", __dir__)

  PROMPT = '> '
  VERSION = "0.5.0"

  GameWindow.new(VERSION)
end
