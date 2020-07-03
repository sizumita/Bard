defmodule TTS do
  def get(text) do
    request = %GoogleApi.TextToSpeech.V1.Model.SynthesizeSpeechRequest{
      audioConfig: %GoogleApi.TextToSpeech.V1.Model.AudioConfig{
        audioEncoding: "MP3",
        # sampleRateHertz: 44100,
        speakingRate: 0.9
      },
      input: %GoogleApi.TextToSpeech.V1.Model.SynthesisInput{
        text: text
      },
      voice: %GoogleApi.TextToSpeech.V1.Model.VoiceSelectionParams{
        languageCode: "ja-JP",
        name: "ja-JP-Wavenet-D"
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
end
