class WidgetsController < ApplicationController
  def index
    Widget.find_by_sql("select sleep(1)")
    render :text => "Oh hai"
  end

  def http
    # going meta, query yourself, on the same thin server!
    http = EM::HttpRequest.new("http://#{request.host}:#{request.port}/widgets").get
    render :text => http.response
  end

  def recurse
    enum = Enumerator.new do |y|
      begin
        recursion(y)
      rescue SystemStackError => e
        y << e.message + "\r\n"
      else
        y << "You didn't reach the limit ! thx ruby 2.0!\r\n"
      ensure
        y << "RUBY_FIBER_VM_STACK_SIZE: #{ENV['RUBY_FIBER_VM_STACK_SIZE'].inspect}\r\n"
      end
    end
    headers["Content-Type"] = 'text/plain'
    self.response_body = enum
  end

protected

  def recursion(yielder, i=1)
    return 0 if i <= 0
    yielder << "recursion #{i}\r\n"
    recursion(yielder, i + 1)
  end

end
