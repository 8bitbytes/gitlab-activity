# frozen_string_literal: true

require 'glimmer-dsl-libui'
require 'require_all'
require_all './models/event_messages'
require './presenters/settings_presenter'

module Control
  class SettingsTab
    include Glimmer::LibUI::CustomControl

    options :presenter

    body {
      tab_item("Settings"){
        content(presenter, computed_by: [:show_pac, :enable_save_settings_button, :refresh]) {
          vertical_box {
            padded true
            stretchy true
            form {
              entry { |e|
                stretchy false
                label 'Gitlab User Name'
                text presenter.fetch_value(:gitlab_user_name)
                on_changed do
                  presenter.handle_value_change(:gitlab_user_name, e.text)
                end
              }
              if presenter.show_pac
                entry { |e|
                  stretchy false
                  label 'Gitlab Personal Access Token'
                  text presenter.fetch_value(:gitlab_personal_access_token)
                  on_changed do
                    presenter.handle_value_change(:gitlab_personal_access_token, e.text)
                  end
                }

                button('Hide Personal Access Token') {
                  stretchy false
                  on_clicked do
                    presenter.show_pac = false
                  end
                }
              else
                password_entry { |pe|
                  stretchy false
                  label 'Gitlab Personal Access Token'
                  text presenter.fetch_value(:gitlab_personal_access_token)
                  on_changed do
                    presenter.handle_value_change(:gitlab_personal_access_token, pe.text)
                  end
                }
                button('Show Personal Access Token') {
                  stretchy false
                  on_clicked do
                    presenter.show_pac = true
                  end
                }
              end
              entry { |e|
                stretchy false
                label 'Gitlab URL https://'
                text presenter.fetch_value(:gitlab_url)
                on_changed do
                  presenter.handle_value_change(:gitlab_url, e.text)
                end
              }
              entry { |e|
                stretchy false
                label 'Check Interval In Minutes'
                text presenter.fetch_value(:check_interval_in_minutes)
                on_changed do
                  presenter.handle_value_change(:check_interval_in_minutes, e.text)
                end
              }
              #TODO: work this out later. Deciding if I want it
              # entry { |e|
              #   stretchy false
              #   label 'Force Notificiation Interval In Minutes'
              #   text presenter.fetch_value(:force_notification_interval_in_minutes)
              #   on_changed do
              #     presenter.handle_value_change(:force_notification_interval_in_minutes, e.text)
              #   end
              # }
              area {
                text {
                  string('Note: Interval changes will be applied immediately after save. Other changes will cause the application to restart'){color :white}
                }
                on_draw do
                  # hacky things incoming
                  presenter.on_load
                end
              }
            }
          }
        }
      }
    }
  end
end

