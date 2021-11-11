module Gosu
  # Window as a GameState
  class Window
    attr_accessor :caption
    attr_reader :width, :height
    attr_writer :current_window

    def initialize(width, height, *options)
      @width = width
      @height = height
    end

    def draw
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end

    def gamepad_connected(index)
    end

    def gamepad_disconnected(index)
    end

    def needs_cursor?
      true
    end

    def needs_redraw?
      true
    end

    def button_down?(id)
    end

    def close
      @current_window&.close
    end

    def drop(filename)
    end

    def mouse_x
      @current_window&.mouse_x
    end

    def mouse_y
      @current_window&.mouse_y
    end

    def mouse_x=(i)
      @current_window&.mouse_x = i
    end

    def mouse_y=(i)
      @current_window&.mouse_y = i
    end

    def text_input
      @current_window&.text_input
    end

    def text_input=(text_input)
      @current_window&.text_input = text_input
    end
  end
end