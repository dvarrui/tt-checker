class ExpectSequence
  def initialize(lines)
    @lines = lines
  end

  def is_valid?(&block)
    @expected = []
    @real = []
    @current_state = true
    @last_index = -1
    instance_eval(&block)
    @current_state
  end

  def expected
    @expected.join(" then ")
  end

  def real
    @real.join(" then ")
  end

  private

  def find(value)
    @expected << "find(#{value})"
    index = get_index_of(value)

    if index > @last_index
      @real << "find(#{value})"
      @last_index = index
      return
    end

    @real << "no find(#{value})"
    @current_state = false
  end

  def next_with(value)
    @expected << "next_with(#{value})"

    line = @lines[@last_index + 1]
    if line.include? value
      @real << "next_with(#{value})"
      @last_index += 1
      return
    end
    @real << "no next_with(#{value})"
    index = get_index_of(value)
    @last_index = index unless index.nil?
    @current_state = false
  end

  def get_index_of(value)
    @lines.each_with_index do |line, index|
      if value.is_a? String
        return index if line.include? value
      elsif value.is_a? Regexp
        return index if value.match(line)
      else
        puts "[ERROR] expect_sequence #{value.class}"
        exit 1
      end
    end
    nil
  end
end
