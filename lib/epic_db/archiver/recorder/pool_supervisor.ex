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
      size: Application.get_env(:epic_db, :recorder_pool_size),
      max_overflow: Application.get_env(:epic_db, :recorder_pool_max_overflow)
    ]

    children = [
      :poolboy.child_spec(EpicDb.Archiver.Recorder.Worker, pool_options, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
