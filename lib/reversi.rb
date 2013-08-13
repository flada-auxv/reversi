class Reversi
  attr_accessor :board

  def initialize
    n = nil
    b = true
    w = false

    @board = [
      [n,n,n,n,n,n,n,n],
      [n,n,n,n,n,n,n,n],
      [n,n,n,n,n,n,n,n],
      [n,n,n,w,b,n,n,n],
      [n,n,n,b,w,n,n,n],
      [n,n,n,n,n,n,n,n],
      [n,n,n,n,n,n,n,n],
      [n,n,n,n,n,n,n,n]
    ]
  end

  def move_black(x, y)
    @board[x][y] = true
  end

  def move_white(x, y)
    @board[x][y] = false
  end
end
