class ChaosPenguinGame
    class Minimap

        attr_accessor :position

        def initialize(map)
            @map = map
            @map_data = []
            @width = 0
            @height = 0
            @position = Omega::Vector3.new(0, 0, 10_000)
            @frame = 0
            @block_size = 3
            update_map_data([])
        end

        def update(entities)
            if @frame % 3 == 0
                update_map_data(entities)
            end
            @frame += 1
        end

        def draw
            x = 0
            y = 0

            @position.x = Omega.width - @width * @block_size - 10
            @position.y = 10

            Gosu.draw_rect(@position.x, @position.y, @width*@block_size, @height*@block_size, Gosu::Color::WHITE, @position.z)
            @map_data.each do |md|
                color = ((md == 0) ? nil : Gosu::Color.new(200, 0, 0, 0))
                color = ((md == 2) ? Gosu::Color.new(255, 255, 0, 0) : color)
                color = ((md == 3) ? Gosu::Color.new(255, 0, 255, 0) : color)
                Gosu.draw_rect(@position.x + x, @position.y + y, @block_size, @block_size, color, @position.z) if color

                x += @block_size
                if x/@block_size >= @width
                    x = 0
                    y += @block_size
                end
            end
        end

        def update_map_data(entities)
            @map_data = []
            @width = @map.width / @map.tile_size
            @height = @map.height / @map.tile_size

            for y in 0...@height
                for x in 0...@width
                    tile = @map.tile_at("solid", x, y)
                    if tile and tile.type == "solid"
                        @map_data << 1
                    else
                        @map_data << entities_at(entities, x, y)
                    end
                end
            end
        end

        def entities_at(entities, x, y)
            entities.each do |e|
                tpos = Omega::Vector2.new(((e.x - e.width_scaled*e.origin.x)/@map.tile_size).to_i, (e.y/@map.tile_size - 1).to_i)

                if tpos.x == x and tpos.y == y
                    if e.is_a? ChaosPenguin
                        return 2
                    else
                        return 3
                    end
                end
            end
            return 0
        end

    end
end