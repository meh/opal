class Proc
  def self.new(&block)
    raise ArgumentError, 'tried to create Proc object without a block' unless block_given?

    block
  end

  def to_proc
    self
  end

  def call(*)
    `this.apply(this.$S, $slice.call(arguments, 0))`
  end

  def to_proc
    self
  end

  def to_s
    "#<Proc:0x0000000>"
  end

  def lambda?
    `!!this.$lambda`
  end

  def arity
    `this.length - 1`
  end
end
