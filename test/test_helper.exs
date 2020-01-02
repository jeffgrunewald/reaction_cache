ExUnit.start()

defmodule TestHelper do
  def eventually(assertion_function, dwell \\ 500, retries \\ 5) do
    case Patiently.wait_for!(
           wrap_assertions_as_falsey(assertion_function),
           dwell: dwell,
           max_tries: retries
         ) do
      :ok -> :ok
      _ -> assertion_function.()
    end
  end

  defp wrap_assertions_as_falsey(function) do
    fn ->
      try do
        function.()
      rescue
        ExUnit.AssertionError ->
          false
      end
    end
  end
end
