class FakeOpenSearch
  @@indices = Hash.new { |h, k| h[k] = {} }
  def initialize(*args); end

  def index(index:, id:, body:)
    @@indices[index][id] = body
  end

  def get(index:, id:)
    { '_source' => @@indices[index][id] }
  end

  def indices
    self
  end

  def delete(index:)
    @@indices.delete(index)
  end

  def create(index:)
    @@indices[index] ||= {}
  end
end
