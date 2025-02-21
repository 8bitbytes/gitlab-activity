# frozen_string_literal: true

require 'glimmer-dsl-libui'
require 'require_all'
require_all './models/event_messages'

module Control
  class IssuesTab
    include Glimmer::LibUI::CustomControl

    options :presenter

    body {
      tab_item(presenter.title_text){
        padded false
        @issue_table = table {
          text_column('Title')
          text_column('Description')
          text_column('Url')
          button_column('Action'){
            on_clicked do |row|
              url = presenter.issue_list[row].url
              `open #{url}`
            end
          }
          cell_rows <= [presenter, :issue_list, {column_attributes: {'Title' => :title, 'Description' => :description,'Url' => :url}}]
        }
        presenter.area = area {
          on_draw do
            # hacky things incoming
            text {
              y 10
              x 10
              string(presenter.status_text){color presenter.status_color}
              string("\n\n\n#{presenter.reload_countdown_text}"){color :yellow}
            }
            presenter.on_load
          end
        }
      }
    }
  end
end

