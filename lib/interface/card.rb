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

        if File.exists?("#{GosuGameJamArcade::GAME_ROOT_PATH}/media/games/#{banner}")
          @banner_image = get_image("#{GosuGameJamArcade::GAME_ROOT_PATH}/media/games/#{banner}")
        else
          @banner_image = Gosu.render(630, 500) do
            Gosu.draw_quad(
              0, 0, rand(0xff_222222..0xff_ffffff),
              630, 0, rand(0xff_222222..0xff_ffffff),
              630, 500, rand(0xff_222222..0xff_ffffff),
              0, 500, rand(0xff_222222..0xff_ffffff)
            )
          end
        end
        @banner_image_scale = [630.0 / @banner_image.width, 500.0 / @banner_image.height].min

        banner_image_height = @banner_image.height * @banner_image_scale

        @title_text = CyberarmEngine::Text.new("<b>#{@title}</b>", size: 48, shadow: true, border: false, shadow_size: 1, shadow_color: 0xff_000000, x: PADDING, y: PADDING + banner_image_height)
        @authors_text = CyberarmEngine::Text.new(@authors, size: 18, color: 0xaa_ffffff, shadow: true, border: false, shadow_size: 1, shadow_color: 0xff_000000, x: PADDING, y: PADDING + banner_image_height + @title_text.height)
        @description_text = CyberarmEngine::Text.new(@description, size: 24, shadow: true, border: false, shadow_size: 1, shadow_color: 0xff_000000, x: PADDING, y: PADDING + banner_image_height + @title_text.height + @authors_text.height)

        handle_text_wrapping(width - PADDING * 2)
      end

      def draw
        Gosu.draw_rect(
          0, 0, (@banner_image.width * @banner_image_scale) + PADDING * 2, (@banner_image.height * @banner_image_scale) + PADDING * 2, 0xaa_222222
        )
        @banner_image.draw(PADDING, PADDING, 0, @banner_image_scale, @banner_image_scale)

        @title_text.draw
        @authors_text.draw
        @description_text.draw
      end

      def width
        @banner_image.width * @banner_image_scale + PADDING * 2
      end

      def height
        @banner_image.height * @banner_image_scale + PADDING * 2 + @title_text.height + @description_text.height + @authors_text.height
      end

      def handle_text_wrapping(max_width, wrap_behavior = :word_wrap)
        copy = @description.to_s.dup

        if line_width(copy[0]) <= max_width && line_width(copy) > max_width && wrap_behavior != :none
          breaks = []
          line_start = 0
          line_end   = copy.length

          while line_start != copy.length
            if line_width(copy[line_start...line_end]) > max_width
              line_end = ((line_end - line_start) / 2.0)
              line_end = 1.0 if line_end <= 1
            elsif line_end < copy.length && line_width(copy[line_start...line_end + 1]) < max_width
              # To small, grow!
              # TODO: find a more efficient way
              line_end += 1

            else # FOUND IT!
              entering_line_end = line_end.floor
              max_reach = line_end.floor - line_start < 63 ? line_end.floor - line_start : 63
              reach = 0

              if wrap_behavior == :word_wrap
                max_reach.times do |i|
                  reach = i
                  break if copy[line_end.floor - i].to_s.match(/[[:punct:]]| /)
                end

                line_end = line_end.floor - reach + 1 if reach != max_reach # Add +1 to walk in front of punctuation
              end

              breaks << line_end.floor
              line_start = line_end.floor
              line_end = copy.length

              break if entering_line_end == copy.length || reach == max_reach
            end
          end

          breaks.each_with_index do |pos, index|
            copy.insert(pos + index, "\n") if pos + index >= 0 && pos + index < copy.length
          end
        end

        @description_text.text = copy
      end

      def line_width(text)
        (@description_text.textobject.markup_width(text))
      end
    end
  end
end
