# frozen_string_literal: true


module Control
  class TextLabel
    def initialize(label_text,
                   width: 80, height: 30, font_descriptor: {},
                   background_fill: {a: 0}, text_color: :black, border_stroke: {a: 0},
                   text_x: nil, text_y: nil,
                   &content)
      area { |the_area|
        rectangle(1, 1, width, height) {
          fill background_fill
        }
        rectangle(1, 1, width, height) {
          stroke border_stroke
        }

        text_height = (font_descriptor[:size] || 12) * (OS.mac? ? 0.75 : 1.35)
        text_width = (text_height * label_text.size) * (OS.mac? ? 0.75 : 0.60)
        text_x ||= (width - text_width) / 2.0
        text_y ||= (height - 4 - text_height) / 2.0
        text(text_x, text_y, width) {
          string(label_text) {
            color text_color
            font font_descriptor
          }
        }

        content&.call(the_area)
      }
    end
  end
end