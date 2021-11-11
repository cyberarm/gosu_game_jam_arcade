module Omega
    class Text
        attr_accessor :position, :scale, :text, :color, :mode

        def initialize(path, size)
            @@fonts ||= {}
            change_font(path, size)
            @position = Omega::Vector3.new(0, 0, 0)
            @scale = Omega::Vector2.new(1, 1)
            @text = ""
            @color = Gosu::Color::WHITE
            @mode = :default
        end

        def draw
            $font.draw_markup(text,
                             @position.x,
                             @position.y,
                             @position.z,
                             @scale.x,
                             @scale.y,
                             @color,
                             @mode)
        end

        def change_font(path, size)
            path = "default" if path.size == 0
            if not @@fonts[path+"_#{size}"]
                if path == "default"
                    @@fonts[path+"_#{size}"] = Gosu::Font.new(size)
                else
                    @@fonts[path+"_#{size}"] = Gosu::Font.new(size, name: path)
                end
            end

            @font = @@fonts[path]
        end

        def alpha=(alpha)
            @color = Gosu::Color.new(alpha, @color.red, @color.green, @color.blue)
        end

        def alpha
            return @color.alpha
        end

    end
end