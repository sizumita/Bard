defmodule TTS do
  def get(text, data) do
    request = %GoogleApi.TextToSpeech.V1.Model.SynthesizeSpeechRequest{
      audioConfig: %GoogleApi.TextToSpeech.V1.Model.AudioConfig{
        audioEncoding: "MP3",
        sampleRateHertz: 44100,
        speakingRate: TTS.get_speed(data),
        pitch: TTS.get_pitch(data)
      },
      input: %GoogleApi.TextToSpeech.V1.Model.SynthesisInput{
        text: text
      },
      voice: %GoogleApi.TextToSpeech.V1.Model.VoiceSelectionParams{
        languageCode: "ja-JP",
        name: TTS.get_voice(data)
      }
    }

    {:ok, token} = Goth.Token.for_scope("https://www.googleapis.com/auth/cloud-platform")
    conn = GoogleApi.TextToSpeech.V1.Connection.new(token.token)

    {:ok, response} =
      GoogleApi.TextToSpeech.V1.Api.Text.texttospeech_text_synthesize(
        conn,
        body: request
      )
      Base.decode64!(response.audioContent)
  end

  def get_voice(data) do
    if data == nil do
      "ja-JP-Wavenet-A"
    else
      case data["voice"] do
        "A" -> "ja-JP-Wavenet-A"
        "B" -> "ja-JP-Wavenet-B"
        "C" -> "ja-JP-Wavenet-C"
        _ -> "ja-JP-Wavenet-D"
      end
    end
  end

  def get_speed(data) do
    if data == nil do
      1.0
    else
      data["speed"]
    end
  end

  def get_pitch(data) do
    if data == nil do
      0.0
    else
      data["pitch"]
    end
  end
end
