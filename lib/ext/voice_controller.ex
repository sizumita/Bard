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

  def has_state(guild) do
    state = Enum.find(guild.voice_states, fn vstate ->
      vstate.user_id == "727687910643466271"
    end)

    if state == nil do
      false

    else
      true
    end
  end

  def wait_for_front(guild, message_id) do
    # Queue.add(:global.whereis_name("V"<>guild.id), message.id) してから
    # :ok = VoiceClientController.wait_for_front(guild, message.id)　をして
    # 処理をする
    pid = :global.whereis_name("V"<>guild.id)
    # :ok = Process.sleep(400)
    case Voice.is_playing(guild.id) do
      {:ok, true} ->
        Voice.wait_for_end(guild.id)
        Process.sleep(200)
      _ -> :ignore
    end
    [head | _] = Queue.list(pid)
    if head == message_id do
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
              case ChannelMap.fetch(:channels, guild.id) do
                {:ok, _} -> Cogs.say "既に接続されています。切断してから再接続してください。"

                :error ->
                  # TODO: ここで課金の確認
                  Voice.join(guild.id, state.channel_id)
                  Cogs.say "接続しました。"
                  {:ok, pid} = Queue.start_link()
                  :global.register_name("V"<>guild.id, pid)

                  ChannelMap.put(:channels, guild.id,
                    %{:text_id => message.channel_id, :voice_id => state.channel_id})

                end
            _ -> Cogs.say "ボイスチャンネルに接続しているユーザのみ可能です。"
            end
        _ -> Cogs.say "サーバー内で実行してください。"
      end
    end

    Cogs.def leave do
      case Cogs.guild() do
        {:ok, guild} ->
          case ChannelMap.fetch(:channels, guild.id) do
            :error ->
              Cogs.say "このサーバーでは接続されていません。"
            {:ok, value} ->
              if value.text_id != message.channel_id do
                Cogs.say "このチャンネルは接続されていません。"
              else
                case VoiceClientController.context(guild, message) do
                  {:ok, state} ->
                    if state.channel_id == value.voice_id do
                      case Voice.is_playing(guild.id) do
                        {:ok, true} ->
                          Voice.stop_audio(guild.id)
                        _ -> :ignore
                      end
                      Voice.leave(guild.id)
                      ChannelMap.delete(:channels, guild.id)
                      Cogs.say "退出しました。"
                    else
                      Cogs.say "同じボイスチャンネルに接続しているユーザのみ可能です。"
                    end
                  _ -> Cogs.say "ボイスチャンネルに接続しているユーザのみ可能です。"
                end
              end
          end
        _ -> Cogs.say "サーバー内で実行してください。"
      end
    end
  end
end
