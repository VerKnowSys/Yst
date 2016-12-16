defmodule Results do
  @moduledoc """
  Simple immutable Results queue genserver
  """
  use GenServer
  @name __MODULE__


  @doc false
  def start_link do
    GenServer.start_link @name, [], name: @name
  end


  @doc """
  Handle synchronous :show which returns Results state
  """
  def handle_call :show, _from, state do
    {:reply, state, state}
  end


  @doc """
  Handle asynchronous :reset which clears Results state
  """
  def handle_cast :reset, _state do
    {:noreply, []}
  end


  @doc """
  Handle asynchronous :push which adds new result to Results state
  """
  def handle_cast {:push, item}, state do
    {:noreply, [item | state]}
  end


  @doc """
  Push new result to queue
  """
  def push sth do
    GenServer.cast @name, {:push, sth}
  end


  @doc """
  Show all results
  """
  def show do
    GenServer.call @name, :show
  end


  @doc """
  Reset results
  """
  def reset do
    GenServer.cast @name, :reset
  end

end
