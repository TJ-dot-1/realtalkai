module.exports = async function handler(req, res) {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    const { messages, scenarioContext, characterName, sessionId } = req.body;

    if (!messages || !Array.isArray(messages)) {
      return res.status(400).json({ error: 'messages array is required' });
    }

    const apiKey = process.env.OPENAI_API_KEY;
    const baseUrl = process.env.OPENAI_BASE_URL || 'https://openrouter.ai/api/v1';
    const feedbackModel = process.env.FEEDBACK_MODEL || 'gpt-4.1-mini';

    if (!apiKey) {
      return res.status(500).json({ error: 'OPENAI_API_KEY not configured' });
    }

    // Build transcript from non-system messages
    const transcript = messages
      .filter(m => m.role !== 'system')
      .map(m => `${m.role === 'user' ? 'LEARNER' : (characterName || 'AI').toUpperCase()}: ${m.content}`)
      .join('\n');

    const feedbackPrompt = `Analyze this English conversation between a language learner and an AI character named ${characterName || 'AI'}.

SCENARIO CONTEXT: ${scenarioContext || 'General conversation'}

CONVERSATION TRANSCRIPT:
${transcript}

Provide a detailed analysis as a JSON object with this exact structure:
{
  "confidenceScore": <0-100 integer>,
  "fluencyScore": <0-100 integer>,
  "grammarCorrections": [
    {"original": "<exact text with error>", "corrected": "<corrected version>", "explanation": "<brief rule explanation>"}
  ],
  "improvedResponses": [
    {"userSaid": "<what user said>", "betterWay": "<improved version>", "why": "<brief explanation>"}
  ],
  "strengths": ["<strength 1>", "<strength 2>"],
  "areasToImprove": ["<area 1>", "<area 2>"],
  "overallFeedback": "<2-3 sentence personalized summary>"
}

SCORING GUIDELINES:
- confidenceScore: How confidently the learner communicated (hesitation, clarity, directness)
- fluencyScore: Overall language quality (grammar, vocabulary, natural flow)
- Focus on the top 3-5 most important issues only
- Be specific with examples from the actual conversation
- Be encouraging but honest

Respond with ONLY the JSON object, no markdown formatting.`;

    const response = await fetch(`${baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: feedbackModel,
        messages: [
          { role: 'system', content: 'You are an expert English language coach. Analyze conversations and provide actionable feedback.' },
          { role: 'user', content: feedbackPrompt },
        ],
        temperature: 0.3,
        max_tokens: 1000,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('Feedback API error:', response.status, errorText);
      return res.status(response.status).json({ error: `AI API error: ${response.status}` });
    }

    const data = await response.json();
    let content = data.choices?.[0]?.message?.content || '';

    // Parse JSON from response (handle potential markdown wrapping)
    content = content.trim();
    if (content.startsWith('```')) {
      content = content.substring(content.indexOf('{'), content.lastIndexOf('}') + 1);
    }

    try {
      const feedback = JSON.parse(content);
      feedback.sessionId = sessionId || 'unknown';
      return res.status(200).json(feedback);
    } catch (parseError) {
      console.error('Failed to parse feedback JSON:', parseError, content);
      // Return default feedback
      return res.status(200).json({
        sessionId: sessionId || 'unknown',
        confidenceScore: 50,
        fluencyScore: 50,
        grammarCorrections: [],
        improvedResponses: [],
        strengths: ['Completed the conversation'],
        areasToImprove: ['Keep practicing for more detailed feedback'],
        overallFeedback: 'Unable to generate detailed feedback. Please try again.',
      });
    }
  } catch (error) {
    console.error('Feedback API error:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};
