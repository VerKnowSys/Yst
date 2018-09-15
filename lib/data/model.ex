use TransactMacro


defdatabase Model do
  @moduledoc """
  Basic data Model for Amnesia, Elixir 1.3.x:

  RecordedScenario:
    uuid,
    timestamp,
    content,
    metadata

  """

  deftable RecordedScenario,
    [:uuid, :content, :metadata, :timestamp],
    type: :ordered_set do
      @type t :: %RecordedScenario{
        uuid: String.t,
        content: String.t,
        metadata: String.t,
        timestamp: String.t
      }
  end

end
