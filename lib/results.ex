defmodule Results do
  @moduledoc """
  Simple immutable Results queue genserver
  """
  use GenServer


  def start_link do
    GenServer.start_link Results, [], name: __MODULE__
  end


  # Callbacks
  def handle_call :pop, _from, [h|t] do
    {:reply, h, t}
  end

  def handle_call :show, _from, state do
    {:reply, state, state}
  end

  def handle_cast {:push, item}, state do
    {:noreply, [item | state]}
  end


  @doc """
  Push new result to queue
  """
  def push sth do
    GenServer.cast __MODULE__, {:push, sth}
  end


  @doc """
  Show all results
  """
  def show do
    GenServer.call __MODULE__, :show
  end

end
