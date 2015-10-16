class Array
  # compares two arrays to determine if they both contain the same elements
  def same?(y)
    self.sort == y.sort
  end
end