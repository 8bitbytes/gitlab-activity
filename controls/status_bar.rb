# frozen_string_literal: true

require 'glimmer-dsl-libui'
require 'require_all'
require_all './models/event_messages'

module Control
  class StatusBar
    include Glimmer::LibUI::CustomControl
    options :presenter
    body {
      area {
        on_draw do |area_draw_params|
          text {
            string (presenter.status_text ) { color :white }
          }
        end
      }
    }
  end
end