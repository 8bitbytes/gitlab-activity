# frozen_string_literal: true

require 'glimmer-dsl-libui'
require 'require_all'
require_all './models/event_messages'

module Control
  class MrsTabGrid
    include Glimmer::LibUI::CustomControl

    options :presenter

    body {
      tab_item(presenter.title_text){ |ti|
        grid {
          table {
            left 0
            top 0
            hexpand true
            vexpand true
            halign :fill
            valign :fill
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
            cell_rows <= [presenter, :mr_list, { column_attributes: { 'Title' => :title, 'Description' => :description,
                                                                      'Approved' => :approved, 'Url' => :url } }]
          }
        }
        vertical_box {
          padded false
          area {
            text {
              string('Approved 1 / 10')
            }
            on_draw {
            }
          }
          button('Reload') {
            stretchy false

            on_clicked {
              presenter.reload
            }
          }
        }
      }
    }
  end
end

