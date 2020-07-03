defmodule Bard do
  use Application
  alias Alchemy.Client

  defmodule CoreCommands do
    use Alchemy.Cogs

  end

  def start(_type, _args) do
    run = Client.start(Application.fetch_env!(:bard, :token))
    Alchemy.Cogs.set_prefix(Application.fetch_env!(:bard, :prefix))
    IO.puts Application.fetch_env!(:bard, :prefix)
    ChannelMap.start_link(:channels)
    Mongo.start_link(name: :mongo, database: Application.fetch_env!(:bard, :db), pool_size: 2)
    use CoreCommands
    use VoiceClientController.Commands
    use Synthesis

    run
  end
end
