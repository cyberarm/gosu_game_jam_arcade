#--
#
# Chingu -- OpenGL accelerated 2D game framework for Ruby
# Copyright (C) 2009 ippa / ippa@rubylicio.us
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#++

module Chingu
  module GameStates
    #
    # A Chingu::GameState for showing a classic arcade "enter name" screen.
    # Will let the user enter his alias or name with the keyboard or game_pad
    # Intended to be minimalistic. If you wan't something flashy you probably want to do this class yourself.
    #
    class EnterName < Chingu::GameState

      def initialize(options = {})
        super

        Text.create("<u>Please enter your name</u>", :rotation_center => :top_center, :x => $chingu_window.width/2, :y => 10, :size => 40)

        on_input([:holding_up, :holding_w, :holding_gamepad_up], :up)
        on_input([:holding_down, :holding_s, :holding_gamepad_down], :down)
        on_input([:holding_left, :holding_a, :holding_gamepad_left], :left)
        on_input([:holding_right, :holding_d, :holding_gamepad_right], :right)
        on_input([:space, :x, :enter, :gamepad_button_1, :return], :action)
        on_input(:esc, :pop_game_state)

        @callback = options[:callback]
        @columns = options[:columns] || 10

        @string = []
        @texts = []
        @index = 1
        @letter_size = 30
        @letters = %w[ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ! " # % & ( ) [ ] / \\ - = * SPACE DEL ENTER ]

        @y = 140
        @x = ($chingu_window.width - 350)/2

        @letters.each_with_index do |letter, index|
          @texts << Text.create(letter, :x => @x, :y => @y, :size => @letter_size)
          @x += @texts.last.width + 20

          if (index+1) % @columns == 0
            @y += @letter_size
            @x = @texts.first.x
          end
        end

        @selected_color = Color::RED
        @name = Text.create("", :rotaion_center => :top_center, :x => $chingu_window.width/2, :y => 60, :size => 80)
      end

      # Move cursor 1 step to the left
      def left; move_cursor(-1); end

      # Move cursor 1 step to the right
      def right; move_cursor(1); end

      # Move cursor 1 step to the left
      def up; move_cursor(-@columns); end

      # Move cursor 1 step to the right
      def down; move_cursor(@columns); end

      # Move cursor any given value (positive or negative). Used by left() and right()
      def move_cursor(amount = 1)
        @index += amount
        @index = 0                if @index >= @letters.size
        @index = @letters.size-1  if @index < 0

        @texts.each { |text| text.color = Color::WHITE }
        @texts[@index].color = Color::RED

        sleep(0.1)
      end

      def action
        case @letters[@index]
          when "DEL"      then  @string.pop
          when "SPACE"    then  @string << " "
          when "ENTER"    then  go
          else            @string << @letters[@index]
        end

        @name.text = @string.join
        @name.x = $chingu_window.width/2 - @name.width/2
      end

      def go
        @callback.call(@name.text)
        pop_game_state
      end

    end
  end
end
