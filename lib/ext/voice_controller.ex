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

  def wait_for_front(guild, message_id) do
    # Queue.add(:global.whereis_name("V"<>guild.id), message.id) してから
    # :ok = VoiceClientController.wait_for_front(guild, message.id)　をして
    # 処理をする
    pid = :global.whereis_name("V"<>guild.id)
    :ok = Process.sleep(200)
    case Voice.is_playing(guild.id) do
      {:ok, true} ->
        IO.puts "waiting...."
        Voice.wait_for_end(guild.id)
      _ -> :ignore
    end
    IO.puts "play..."
    [head | tail] = Queue.list(pid)
    if head == message_id do
      IO.puts head
      Queue.fetch(pid)
      :ok
    else
      VoiceClientController.wait_for_front(guild, message_id)
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
              Cogs.say "接続しました。"
              {:ok, pid} = Queue.start_link()
              :global.register_name("V"<>guild.id, pid)
            _ -> Cogs.say "ボイスチャンネルに入った状態で呼び出す必要があります。"
            end
        _ -> Cogs.say "サーバー内で実行してください。"
      end
    end

    Cogs.def leave do
      case Cogs.guild() do
        {:ok, guild} ->
          case Voice.is_playing(guild.id) do
            {:ok, true} ->
              Voice.stop_audio(guild.id)
            _ -> :ignore
          end
          Voice.leave(guild.id)
          Cogs.say "退出しました。"
        _ -> Cogs.say "サーバー内で実行してください。"
      end
    end
  end
end
