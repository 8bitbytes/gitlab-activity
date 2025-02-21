# frozen_string_literal: true
#
module Service
  class Application
    def restart
      exec("ruby ./main.rb")
      exit(0)
    end
  end
end
