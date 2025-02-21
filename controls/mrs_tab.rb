# frozen_string_literal: true

require 'glimmer-dsl-libui'
require 'require_all'
require_all './models/event_messages'

module Control
  class MrsTab
    include Glimmer::LibUI::CustomControl

    options :presenter

    body {
      tab_item(presenter.title_text){ |ti|
        padded false

        presenter.mr_table = table {
            text_column('Title')
            text_column('Description')
            checkbox_column('Approved') {
              editable false
            }
            text_column('Url')
            button_column('Action'){
              on_clicked do |row|
                url = presenter.mr_list[row].url
                `open #{url}`
              end
            }
            cell_rows <=> [presenter, :mr_list, { column_attributes: { 'Title' => :title, 'Description' => :description,
                                                                      'Approved' => :approved, 'Url' => :url } }]
          }
        presenter.status_area = area {
            on_draw { |area_params|
              text {
                y 10
                x 10
                string(presenter.status_text){color presenter.status_color}
                string("\n\n\n#{presenter.reload_countdown_text}"){color :yellow}
              }
              presenter.on_load
            }
          }
      }
    }
  end
end

