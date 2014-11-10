defmodule EpicDb.Archiver.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(EpicDb.Archiver.Recorder,  [[name: EpicDb.Archiver.Recorder]]),
      worker(EpicDb.Archiver.Consumer,  [[name: EpicDb.Archiver.Consumer]])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
