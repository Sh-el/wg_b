defmodule WgWeb.RequestLimiter.Server do
  @moduledoc """
  A server that limits the number of requests that can be made within a given time interval.
  When started with `start_link/1`, it initializes with a maximum number of requests allowed per minute.
  The `get_token/0` function is used to retrieve a token for a request, while the `number_tokens/0`
  function returns the number of available tokens.
  If there are no more tokens available, a `{:error, :no_tokens}` response is returned.
  """
  use GenServer

  def start_link(max_reqs_per_min) do
    GenServer.start_link(__MODULE__, max_reqs_per_min, name: __MODULE__)
  end

  def get_token() do
    GenServer.call(__MODULE__, :get_token)
  end

  def number_tokens() do
    GenServer.call(__MODULE__, :number_tokens)
  end

  @impl GenServer
  def init(max_reqs_per_min) do
    token_refresh_interval = div(60_000, max_reqs_per_min)
    :timer.send_interval(token_refresh_interval, :update)
    {:ok, %{tokens: max_reqs_per_min, max_reqs_per_min: max_reqs_per_min}}
  end

  @impl GenServer
  def handle_info(:update, %{tokens: count, max_reqs_per_min: max_reqs_per_min} = state) do
    updated_tokens = min(count + 1, max_reqs_per_min)
    {:noreply, %{state | tokens: updated_tokens}}
  end

  @impl GenServer
  def handle_call(:number_tokens, _from, %{tokens: tokens} = state) do
    {:reply, tokens, state}
  end

  @impl GenServer
  def handle_call(:get_token, _from, %{tokens: 0} = state) do
    {:reply, {:error, :no_tokens}, state}
  end

  @impl GenServer
  def handle_call(:get_token, _from, %{tokens: tokens} = state) do
    {:reply, :ok, %{state | tokens: tokens - 1}}
  end
end
