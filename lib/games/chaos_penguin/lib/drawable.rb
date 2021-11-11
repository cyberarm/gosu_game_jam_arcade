module Omega

    class Drawable
        def initialize
            @position = Omega::Vector3.new(0, 0, 0)
            @color = Omega::Color.from_color(Omega::Color::WHITE)
        end

        def alpha
            return @color.alpha
        end

        def alpha=(nv)
            @color = Omega::Color.new(nv, @color.red, @color.green, @color.blue)
        end

        def red
            return @color.red
        end

        def red=(r)
            @color.red = r
        end

        def green
            return @color.green
        end

        def green=(g)
            @color.green = g
        end

        def blue
            return @color.blue
        end

        def blue=(b)
            @color.blue = b
        end

        
        # Getters & setters

        # Shortcut to postion.x, position.y & position.z
        def x
            @position.x
        end

        def y
            @position.y
        end

        def z
            @position.z
        end

        def x=(v)
            @position.x = v
        end

        def y=(v)
            @position.y = v
        end

        def z=(v)
            @position.z = v
        end
    end

end