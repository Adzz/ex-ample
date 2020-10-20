# We can turn the following nested case statement...
weather = %{chance_of_rain: 84}
max = 90
min = 1
chance = weather.chance_of_rain

case chance < min do
  true ->
    min

  false ->
    case chance > max do
      true -> max
      false -> chance
    end
end

# Into a with:

with {:too_small, false} <- {:too_small, chance < min},
     {:too_large, false} <- {:too_large, chance > max} do
  {:ok, chance}
else
  {:too_small, true} -> {:ok, min}
  {:too_large, true} -> {:ok, max}
end
