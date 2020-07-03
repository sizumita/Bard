defmodule Synthesis do
  use Alchemy.Events
  alias Alchemy.Client
  alias Alchemy.Voice

  Events.on_message(:inspect)
  def inspect(message) do
    if not message.author.bot do
      {:ok, channel} = Client.get_channel(message.channel_id)
      if channel.__struct__ == Alchemy.Channel.TextChannel do
          case ChannelMap.fetch(:channels, channel.guild_id) do
            {:ok, value} ->
              if channel.id == value.text_id do
                {:ok, guild} = Client.get_guild(channel.guild_id)
                p = TTS.get(message.author.username <> "、" <> message.content)
                Queue.add(:global.whereis_name("V"<>guild.id), message.id)
                :ok = VoiceClientController.wait_for_front(guild, message.id)
                :ok = Voice.play_iodata(guild.id, p)
              end
            _ -> :ignore
          end
      end
    end
  end
end
