require 'ansi/code'

module MiddlemanRefinery
  module Status
    def say_status(status)
      puts "#{ANSI.green{:refinery.to_s.rjust(12)}}  #{status}"
    end
  end
end