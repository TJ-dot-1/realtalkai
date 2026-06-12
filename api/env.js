module.exports = function handler(req, res) {
  // Allow CORS for same-origin fetch from the Flutter app
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET');
  res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate');

  // Only allow GET requests
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (req.method !== 'GET') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  // Return environment variables configured in Vercel project settings
  res.status(200).json({
    OPENAI_API_KEY: process.env.OPENAI_API_KEY || '',
    OPENAI_BASE_URL: process.env.OPENAI_BASE_URL || 'https://openrouter.ai/api/v1',
    CHAT_MODEL: process.env.CHAT_MODEL || 'gpt-5.4-mini',
    FEEDBACK_MODEL: process.env.FEEDBACK_MODEL || 'gpt-5.4-mini',
    AUDIO_API_KEY: process.env.AUDIO_API_KEY || '',
    AUDIO_BASE_URL: process.env.AUDIO_BASE_URL || 'https://api.openai.com/v1',
    GEMINI_API_KEY: process.env.GEMINI_API_KEY || '',
    GEMINI_BASE_URL: process.env.GEMINI_BASE_URL || 'https://generative.googleapis.com/v1',
    API_PROVIDER: process.env.API_PROVIDER || 'openai',
    WHISPER_MODEL: process.env.WHISPER_MODEL || 'whisper-1',
    TTS_MODEL: process.env.TTS_MODEL || 'tts-1',
  });
};
