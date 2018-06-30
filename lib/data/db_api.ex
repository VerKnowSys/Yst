defmodule DbApi do
  @moduledoc """
  Model Backend module.
  """
  require Logger

  require TransactMacro
  import TransactMacro
  use TransactMacro


  defp create_amnesia_schema do
    case Amnesia.Schema.create() do
      :ok ->
        Logger.info "Amnesia Schema created"

      {:error, {_, {:already_exists, a_node}}} ->
        Logger.info "Amnesia schema already created for node: #{a_node}"

      {:error, {_, {err, a_node}}} ->
        Logger.error "Amnesia schema cannot be created for a_node: #{a_node} cause: #{inspect err}"

      _ ->
        Logger.info "Wildcard!!"
    end
  end


  def init_and_start do
    Amnesia.stop()
    for dir <- [Cfg.mnesia_dumps_dir(), Cfg.project_dir()] do
      File.mkdir_p dir
    end
    create_amnesia_schema()
    Amnesia.start()
    # Logger.debug "Schema dump:\n#{Amnesia.Schema.print()}"

    result = Model.create disk: [node()]
    Logger.info "Created amnesia node: #{inspect result}"
    Logger.info "-----------------------------------------"
    Logger.info "#{inspect Amnesia.info}"
    Logger.info "-----------------------------------------"
  end


  def dump_mnesia param \\ "" do
    File.mkdir_p Cfg.mnesia_dumps_dir()
    case param do
      "" ->
        dump_db_file Utils.timestamp() |> (String.replace ~r/[:. ]/, "-")
      a_name ->
        dump_db_file a_name
    end
  end


  def dump_db_file tstamp do
    dump_name = "#{Cfg.mnesia_dumps_dir()}mnesia-db.#{tstamp}.erl"
    Logger.info "Dumping database to file: #{dump_name}"
    Amnesia.dump "#{dump_name}"
  end


  defp destroy_schema do
    Logger.warn "Stopping and destroying Amnesia schema"
    Amnesia.stop
    Amnesia.Schema.destroy()
  end


  def destroy do
    Logger.warn "Destroying database"
    list = Model.destroy()
    Logger.info "Mnesia databases destroyed: #{inspect list}"
    destroy_schema()
    Logger.info "Mnesia schema destroyed."
  end


  def close do
    Logger.warn "Shutting down"
    Amnesia.stop()
  end


  @doc """
  Load all stored scenarios.
  """
  def scenarios do
    transact RecordedScenario.where{uuid != ""}
  end


  @doc """
  Helper to create new RecordedScenario
  """
  def scenario_new content, metadata \\ "" do
    transact RecordedScenario.write %RecordedScenario{
      uuid: UUID.uuid4(),
      timestamp: Utils.timestamp(),
      content: content,
      metadata: metadata,
    }
  end


end
