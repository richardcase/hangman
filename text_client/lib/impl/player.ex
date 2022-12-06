defmodule TextClient.Impl.Player do


  @typep game :: Hangman.game
  @typep tally :: Hangman.tally
  @typep state :: { game, tally }

  @spec start(game) :: :ok
  def start(game) do
    tally = Hangman.tally(game)

    interact({ game, tally })
  end


  @spec interact(state) :: :ok

  def interact({_game, _tally = %{ game_state: :won }}) do
    IO.puts "Congratulations. You won!"
  end

  def interact({_game, tally = %{ game_state: :lost }}) do
    IO.puts "Sorry, you lost... the word was #{tally.letters |> Enum.join }"
  end

  def interact({game, tally}) do
    IO.puts feedback_for(tally)
    IO.puts current_word(tally)

    tally = Hangman.make_move(game, get_guess())
    interact({game, tally})
  end


  defp feedback_for(tally = %{ game_state: :initializing}) do
    IO.puts("I'm thinking of a word with #{tally.letters |> length} letters")
  end

  defp feedback_for(_tally = %{ game_state: :good_guess }), do: "Good guess!"
  defp feedback_for(_tally = %{ game_state: :bad_guess  }), do: "Sorry, that letter's not in the word"
  defp feedback_for(_tally = %{ game_state: :already_used  }), do: "You already used that letter"

  defp current_word(tally) do
    [
      "Word so far: ",
      tally.letters |> Enum.join(" "),
      IO.ANSI.format([:green, "   (turns left: "]),
      tally.turns_left |> to_string,
      IO.ANSI.format([:green, "   used so far: "]),
      tally.used |> Enum.join(","),
      ")"
    ]
  end

  def get_guess() do
    IO.gets("Next letter: ")
    |> String.trim()
    |> String.downcase()
  end

end
