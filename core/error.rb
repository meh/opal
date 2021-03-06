class Exception
  def initialize(message = '')
    %x{
      if (Error.captureStackTrace) {
        Error.captureStackTrace(this);
      }

      this.message = message;
    }
  end

  def backtrace
    %x{
      if (this._bt !== undefined) {
        return this._bt;
      }

      var backtrace = this.stack;

      if (typeof(backtrace) === 'string') {
        return this._bt = backtrace.split("\\n");
      }
      else if (backtrace) {
        this._bt = backtrace;
      }

      return this._bt = ["No backtrace available"];
    }
  end

  def inspect
    "#<#{self.class}: '#{message}'>"
  end

  def message
    `this.message`
  end

  alias to_s message
end
