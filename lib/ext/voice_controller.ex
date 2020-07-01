defmodule VoiceClientController do
  alias Alchemy.Voice

  def context(guild, message) do
    state = Enum.find(guild.voice_states, fn vstate ->
      vstate.user_id == message.author.id
    end)

    if state == nil do
      {:error, "No state found"}

    else
      {:ok, state}
    end
  end

  defmodule Commands do
    use Alchemy.Cogs

    Cogs.def join do
      case Cogs.guild() do
        {:ok, guild} ->
          case VoiceClientController.context(guild, message) do
            {:ok, state} ->
              Voice.join(guild.id, state.channel_id)
              # TODO: ここで課金の確認
              Cogs.say "起動成功しました。"
            _ -> Cogs.say "ボイスチャンネルに入った状態で呼び出す必要があります。"
            end
        _ -> Cogs.say "サーバー内で実行してください。"
      end
    end
  end
end
