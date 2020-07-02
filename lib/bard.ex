defmodule Bard do
  use Application
  alias Alchemy.Client
  use Alchemy.Events

  Events.on_message(:inspect)
  def inspect(message), do: IO.inspect message.content

  defmodule CoreCommands do
    use Alchemy.Cogs

    Cogs.def help do
      Cogs.say "help"
    end
  end

  def start(_type, _args) do
    run = Client.start(Application.fetch_env!(:bard, :token))
    Alchemy.Cogs.set_prefix(Application.fetch_env!(:bard, :prefix))
    IO.puts Application.fetch_env!(:bard, :prefix)
    ChannelMap.start_link(:channels)
    use CoreCommands
    use VoiceClientController.Commands
    # use Music.Commands

    run
  end
end
