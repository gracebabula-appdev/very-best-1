# Be sure to restart your server when you modify this file.

# You can add backtrace silencers for libraries that you're using but don't wish to see in your backtraces.
# Rails.backtrace_cleaner.add_silencer { |line| line =~ /my_noisy_library/ }

# You can also remove all the silencers if you're trying to debug a problem that might stem from framework code.
# Rails.backtrace_cleaner.remove_silencers!


Rails.backtrace_cleaner.add_silencer { |line| line =~ /lib|gems/ }

module ActionDispatch
  class ExceptionWrapper
    def framework_trace
      []
    end
  end
end

module ActionDispatch
  module Routing
    class RouteSet
      def draw(&block)
        clear! unless @disable_clear_and_finalize
        eval_block(block)
        finalize! unless @disable_clear_and_finalize
        nil
      rescue => e
        nicer_message = e.message
        nicer_message = nicer_message.sub(/for .+/,'.')
        nicer_message = nicer_message.sub('ApplicationController::','')
        nicer_message = nicer_message.sub('uninitialized constant','undefined class')
        nicer_message = nicer_message.sub('undefined local variable or method','unrecognized')
        nicer_message = nicer_message.sub(/ \(/,'')
        nicer_message = nicer_message.sub(/did you mean/, 'Did you mean')

        route_line = e.backtrace.detect { |line| line !~ /\/gems/ }.sub(/^[^\/]+/,'')
        route_line.sub!(/:in .+/,'')
        route_line =~ /(.+):(.+)/

        puts
        puts "ERROR: routes.rb"
        puts nicer_message
        puts route_line
        puts

        rescue_route = proc do
          html = "<h2>There's a problem with your routes.rb file.</h2><p><code>#{nicer_message}</code></p><p><code>#{route_line}</code></p>"
          get '/' => proc {|env| [200, { "Content-Type" => 'text/html'}, [html]]}
          get '*path' => proc {|env| [200, { "Content-Type" => 'text/html'}, [html]]}
        end

        eval_block(rescue_route)
      end
    end
  end
end
