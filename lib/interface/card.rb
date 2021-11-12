class GosuGameJamArcade
  class Interface
    class Card
      include CyberarmEngine::Common
      PADDING = 4

      attr_reader :title, :description, :authors, :banner, :color_hint, :block

      def initialize(title:, description:, authors:, banner:, color_hint:, &block)
        @title = title
        @description = description
        @authors = authors
        @banner = banner
        @color_hint = color_hint

        @block = block

        @banner_image = get_image("#{GosuGameJamArcade::GAME_ROOT_PATH}/media/games/#{banner}")

        @title_text = CyberarmEngine::Text.new("<b>#{@title}</b>", size: 48, shadow: true, border: false, shadow_size: 1, shadow_color: 0xff_000000, x: PADDING, y: PADDING + @banner_image.height)
        @authors_text = CyberarmEngine::Text.new(@authors, size: 18, shadow: true, border: false, shadow_size: 1, shadow_color: 0xff_000000, x: PADDING, y: PADDING + @banner_image.height + @title_text.height)
        @description_text = CyberarmEngine::Text.new(@description, size: 24, shadow: true, border: false, shadow_size: 1, shadow_color: 0xff_000000, x: PADDING, y: PADDING + @banner_image.height + @title_text.height + @authors_text.height)
      end

      def draw
        Gosu.draw_rect(
          0, 0, @banner_image.width + PADDING * 2, @banner_image.height + PADDING * 2, 0xaa_222222
        )
        @banner_image.draw(PADDING, PADDING, 0)

        @title_text.draw
        @authors_text.draw
        @description_text.draw
      end

      def width
        @banner_image.width + PADDING * 2
      end

      def height
        @banner_image.height + PADDING * 2 + @title_text.height + @description_text.height + @authors_text.height
      end
    end
  end
end
