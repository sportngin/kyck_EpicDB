defmodule Mix.Tasks.EpicDb do
  defmodule Version do
    use Mix.Task

    def run(_) do
      IO.puts EpicDb.Mixfile.project[:version]
    end
  end

  defmodule CopyRelease do
    def run(_) do
      version     = EpicDb.Mixfile.project[:version]
      file_name   = "epic_db-#{version}.tar.gz"
      release     = "rel/epic_db/#{file_name}"
      destination = "/releases/staging/#{file_name}"
      File.copy!(release, destination)
    end
  end
end
