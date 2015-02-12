defmodule EpicDb.Archiver.Recorder.PoolSupervisor do
  use Supervisor

  @doc """
  Starts the PoolSupervisor
  """
  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end
  
  def init(_opts) do
    pool_options = [
      name: {:local, EpicDb.Archiver.Recorder.Worker},
      worker_module: EpicDb.Archiver.Recorder.Worker,

      # TODO: Once exrm provides the ability to configure a release from the environment
      # move this to the relevant location. You can see the github issue here:
      # https://github.com/bitwalker/exrm/issues/90
      size: System.get_env("EPICDB_RECORDER_POOL") || 10,
      max_overflow: System.get_env("EPICDB_RECORDER_POOL_OVERFLOW") || 90
    ]

    children = [
      :poolboy.child_spec(EpicDb.Archiver.Recorder.Worker, pool_options, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
