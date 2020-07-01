defmodule Bard do
  use Application

  defmodule CoreCommands do
    use Alchemy.Cogs

    Cogs.def help do
      Cogs.say "help"
    end
  end

  def start(_type, _args) do
    run = Client.start(Application.fetch_env!(:bard, :token))
    Alchemy.Cogs.set_prefix(Application.fetch_env!(:bard, :prefix))
    use CoreCommands
    # use Music.Commands

    run
  end
end
