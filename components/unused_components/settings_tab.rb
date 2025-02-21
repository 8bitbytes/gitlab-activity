=begin
# frozen_string_literal: true

require 'glimmer-dsl-libui'
require './services/message_bus'
module Component
  # setting tab ui component
  class SettingsTab
    include Glimmer

    attr_accessor :settings_service, :show_pac, :enable_save_settings_button

    def initialize
      @settings_service = Service::Settings.instance
      @show_pac = false
      @message_bus = Service::MessageBus.instance
    end

    def settings_tab
      tab_item("Settings"){
        content(self, :show_pac) {
          vertical_box {
            form {
              entry {
                stretchy false
                label 'Gitlab User Name'
                text <=> [@settings_service.settings, :gitlab_user_name, { after_write: lambda do |value|
                  @settings_service.notify_change
                  settings_have_changed = @settings_service.settings_changed?
                  self.enable_save_settings_button = settings_have_changed
                  show_default_status unless settings_have_changed
                end }]
              }
              if show_pac
                entry {
                  stretchy false
                  label 'Gitlab Personal Access Token'
                  text <=> [@settings_service.settings, :gitlab_personal_access_token]
                }
                button('Hide Personal Access Token') {
                  stretchy false
                  on_clicked do
                    self.show_pac = false
                  end
                }
              else
                password_entry {
                  stretchy false
                  label 'Gitlab Personal Access Token'
                  text <=> [@settings_service.settings, :gitlab_personal_access_token]
                }
                button('Show Personal Access Token') {
                  stretchy false
                  on_clicked do
                    self.show_pac = true
                  end
                }
              end
              entry {
                stretchy false
                label 'Check Interval In Minutes'
                text <=> [@settings_service.settings, :check_interval_in_minutes]
              }
              entry {
                stretchy false
                label 'Force Notificiation Interval In Minutes'
                text <=> [@settings_service.settings,
                          :force_notification_interval_in_minutes]
              }
            }
          }
          button('Save Settings') {
            stretchy false
            enabled <= [self, :enable_save_settings_button]
            on_clicked do
              save_settings
            end
          }
        }
      }
    end

    private

    def save_settings
      @settings_service.save_settings
      msg_box('Settings Saved!', 'Settings saved successfully!')
    end

    def show_default_status
      @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Settings loaded', display_for: 0))
    end
  end
end

=end
