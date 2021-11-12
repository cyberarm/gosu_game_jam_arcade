class KeepCalmAndBalanceGame
  class Background
    def initialize()
      dir_path = File.dirname(__FILE__)
      @image = Gosu::Image.new(dir_path + '/../../media/square.png')
    end

    def draw
      @image.draw(0, 0, ZBACKGROUND,
                  scale_x = MAPX, scale_y = MAPY,
                  color = Gosu::Color::BLUE)
    end
  end
end
