# frozen_string_literal: true
# typed: false

require 'glimmer-dsl-libui'
require 'require_all'
require './services/osx_notification'
require './services/status_message_queue'
require './services/settings'
require './services/countdown'
require './controls/mrs_tab'
require './controls/issues_tab'
require './controls/settings_tab'
require './controls/status_bar'
require './controls/mrs_tab_grid'
require './presenters/settings_presenter'
require './presenters/mrs_assigned_to_me_presenter'
require './presenters/status_bar_presenter'
require './presenters/issues_assigned_to_me_presenter'
require './presenters/issues_authored_by_me_presenter'
require './presenters/mrs_authored_by_me_presenter'
require './components/status_bar'
require './components/cta_button'

class GitlabActivityMainWindow
  include Glimmer::LibUI::CustomWindow

  def initialize
    service_initialize
    presenter_initialize
    @message_bus.add_observer(self)
    @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Gitlab activity is running in the background', display_for: 0))
    refresh_interval = @settings_service.settings.check_interval_in_minutes.to_i * 60
    @countdown_service = Service::Countdown.new(countdown_seconds: refresh_interval,
                                                on_timer_complete: method(:send_reload_message), on_tick: method(:timer_tick))

  end

  def service_initialize
    @message_bus = Service::MessageBus.instance
    @settings_service = Service::Settings.instance
  end

  def presenter_initialize
    @settings_presenter = Presenter::SettingsPresenter.new
    @status_bar_presenter = Presenter::StatusBarPresenter.new
    @mrs_assigned_to_me_presenter = Presenter::MrsAssignedToMePresenter.new
    @mrs_authored_by_me_presenter = Presenter::MrsAuthoredByMePresenter.new
    @issues_assigned_to_me_presenter = Presenter::IssuesAssignedToMePresenter.new
    @issues_authored_by_me_presenter = Presenter::IssuesAuthoredByMePresenter.new
  end

  def launch
    Service::OsxNotification.new.show_notification('Gitlab Activity', 'Gitlab Activity is running in the background')
    Service::StatusMessageQueue.instance.process_queue
    start_auto_refresh
    main_window.show
  end

  def update(event_message)
    return unless valid_event_type? event_message

    event_message.changes.each do |change|
      case change[:key]
      when 'check_interval_in_minutes'
        update_countdown_service_seconds(change[:value].to_i * 60)
      end
    end
  end

  private

  attr_accessor :status_text, :mr_list, :mr_authored_by_me_presenter

  def valid_event_type?(event_message)
    event_message.is_a?(Model::EventMessages::SettingsChangedMessage)
  end

  def main_window
    window('Gitlab Activity', 800, 400) {
      margined true

      vertical_box {
        padded false
        grid {
          vertical_box {
            top 0
            left 0
            vexpand true
            hexpand true
            valign :fill
            halign :fill

            tab {
              mrs_tab(presenter: @mrs_assigned_to_me_presenter)
              mrs_tab(presenter: @mrs_authored_by_me_presenter)
              issues_tab(presenter: @issues_authored_by_me_presenter)
              issues_tab(presenter: @issues_assigned_to_me_presenter)
              settings_tab(presenter: @settings_presenter)
            }
          }
          vertical_box {
            top 4
            left 0

            Component::CtaButton.new.create {}
            Component::StatusBar.new.status_bar {}
          }
        }

      }
    }
  end

  def start_auto_refresh
    @countdown_service.start
  end

  def send_reload_message
    @message_bus.publish_message(message: Model::EventMessages::ForceReloadMessage.new)
    @message_bus.publish_message(message: Model::EventMessages::StatusBarUpdateQueueMessage.new(message: 'Reloading all data...', display_for: 3, color: :green))
    reset_reload_countdown
  end

  def reset_reload_countdown
    update_countdown_service_seconds(@settings_service.settings.check_interval_in_minutes.to_i * 60)
  end

  def timer_tick(seconds_remaining)
    @message_bus.publish_message(message: Model::EventMessages::CountdownUpdateMessage.new(seconds_remaining))
  end

  def update_countdown_service_seconds(seconds)
    @countdown_service.change_countdown_seconds(seconds)
    @countdown_service.resume
  end
end