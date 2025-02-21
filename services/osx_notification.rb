# frozen_string_literal: true

module Service
  # Class for showing an osx notification
  class OsxNotification

    def show_notification(title, message)
      system("osascript -e 'display notification \"#{message}\" with title \"#{title}\"'")
    end
  end
end

