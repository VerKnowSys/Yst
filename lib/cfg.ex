defmodule Cfg do
  @moduledoc """
  Module borrowed from CodePot to allow more dynamic configuration.
  """
  require Logger


  defp data_dir_base do
    case :os.type() do
      {:unix, :darwin} -> "/Library/Yst/"
      {:unix, _}       -> "/.Yst/"
    end
  end


  def env, do: System.get_env "MIX_ENV"
  def project_dir, do: (System.get_env "HOME") <> data_dir_base() <> env()
  def mnesia_dumps_dir, do: (System.get_env "HOME") <> data_dir_base() <> ".mnesia-dumps-#{env()}/"


  @doc """
  Returns application version
  """
  def version app_name \\ :yst do
    {:ok, info} = :application.get_all_key app_name
    List.to_string info[:vsn]
  end


  @doc """
  Returns interval between database dumps to disk. Default: 6h
  """
  def dump_interval do
    Application.get_env :yst, :mnesia_autodump_interval
  end


  @doc """
  Sets log level of default Logger
  """
  def log_level level \\ :debug do
    Logger.configure [level: level]
    Logger.configure_backend :console, [level: level]
  end


  @doc false
  def set_default_mnesia_dir data_dir do
    :application.set_env :mnesia, :dir, to_char_list data_dir
  end

end
