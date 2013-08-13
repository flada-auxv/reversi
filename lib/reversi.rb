class Reversi
  attr_accessor :board

  def initialize
    @board = [
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,true,false,nil,nil,nil],
      [nil,nil,nil,false,true,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil],
      [nil,nil,nil,nil,nil,nil,nil,nil]
    ]
  end
end
