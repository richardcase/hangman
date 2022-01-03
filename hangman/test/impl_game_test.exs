defmodule HangmanImplGameTest do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "new game returns structure" do
    game = Game.new_game()

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0

  end

  test "new game returns correct word" do
    game = Game.new_game("wombat")

    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["w", "o", "m", "b", "a", "t"]

  end

  test "new game returns letters which are lower case ascii" do
    game = Game.new_game()

    game.letters
    |> List.to_charlist
    |> Enum.each(fn x -> assert x in 97..126 end)
  end

  test "state doesn't change if a game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("wombat")
      game = Map.put(game, :game_state, state)
      { new_game, _tally } = Game.make_move(game, "x")

      assert new_game == game
    end
  end

  test "a duplicate letter is reported" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "y")
    assert game.game_state != :already_used
    {game, _tally} = Game.make_move(game, "x")
    assert game.game_state == :already_used
  end

  test "we record letters used" do
    game = Game.new_game()
    {game, _tally} = Game.make_move(game, "x")
    {game, _tally} = Game.make_move(game, "y")
    {game, _tally} = Game.make_move(game, "x")
    assert MapSet.equal?(game.used, MapSet.new(["x", "y"]))
  end

  test "we recongnize a letter in the word" do
    game = Game.new_game("wombat")
    {game, tally} = Game.make_move(game, "m")
    assert tally.game_state == :good_guess
    {game, tally} = Game.make_move(game, "t")
    assert tally.game_state == :good_guess
  end

  test "we recongnize a letter mot in the word" do
    game = Game.new_game("wombat")
    {game, tally} = Game.make_move(game, "x")
    assert tally.game_state == :bad_guess
  end

  test "can we handle a sequence of moves" do
    [
      ["a", :bad_guess, 6, ["_","_","_","_","_"], ["a"] ],
      ["a", :already_used, 6, ["_","_","_","_","_"], ["a"] ],
      ["e", :good_guess, 6, ["_","e","_","_","_"], ["a", "e"] ],
      ["x", :bad_guess, 5, ["_","e","_","_","_"], ["a", "e", "x"] ],
    ]
    |> test_sequence_of_moves()
  end

  test "can we handle a winning game" do
    [
      ["a", :bad_guess, 6, ["_","_","_","_","_"], ["a"] ],
      ["a", :already_used, 6, ["_","_","_","_","_"], ["a"] ],
      ["e", :good_guess, 6, ["_","e","_","_","_"], ["a", "e"] ],
      ["x", :bad_guess, 5, ["_","e","_","_","_"], ["a", "e", "x"] ],
      ["l", :good_guess, 5, ["_","e","l","l","_"], ["a", "e", "l", "x"] ],
      ["o", :good_guess, 5, ["_","e","l","l","o"], ["a", "e", "l", "o", "x"] ],
      ["h", :won, 5, ["h","e","l","l","o"], ["a", "e", "h", "l", "o", "x"] ],
    ]
    |> test_sequence_of_moves()
  end

  test "can we handle a failing game" do
    [
      ["a", :bad_guess, 6, ["_","_","_","_","_"], ["a"] ],
      ["a", :already_used, 6, ["_","_","_","_","_"], ["a"] ],
      ["e", :good_guess, 6, ["_","e","_","_","_"], ["a", "e"] ],
      ["x", :bad_guess, 5, ["_","e","_","_","_"], ["a", "e", "x"] ],
      ["l", :good_guess, 5, ["_","e","l","l","_"], ["a", "e", "l", "x"] ],
      ["b", :bad_guess, 4, ["_","e","l","l","_"], ["a", "b", "e", "l", "x"] ],
      ["c", :bad_guess, 3, ["_","e","l","l","_"], ["a", "b", "c", "e", "l", "x"] ],
      ["t", :bad_guess, 2, ["_","e","l","l","_"], ["a", "b", "c", "e", "l", "t", "x"] ],
      ["r", :bad_guess, 1, ["_","e","l","l","_"], ["a", "b", "c", "e", "l", "r", "t", "x"] ],
      ["g", :lost, 0, ["h","e","l","l","o"], ["a", "b", "c", "e", "g", "l", "r", "t", "x"] ],

    ]
    |> test_sequence_of_moves()
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([guess,state,turns,letters,used], game) do
    { game, tally } = Game.make_move(game,guess)

    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used

    game
  end
end
