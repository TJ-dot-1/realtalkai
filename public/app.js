/* ═══════════════════════════════════════════════════════════════
   RealTalk AI — Pure JavaScript Application
   Scenario-Based Language Training
   ═══════════════════════════════════════════════════════════════ */

// ── Data: Characters ───────────────────────────────────────────
const CHARACTERS = [
  {
    id: 'friendly', name: 'Sara', emoji: '😊', type: 'Friendly',
    tone: 'Warm & Encouraging',
    description: 'A warm, outgoing person who loves meeting people. She makes you feel comfortable and encourages you to speak freely.',
    traits: ['Encouraging', 'Patient', 'Casual', 'Supportive'],
    gradientStart: '#00E676', gradientEnd: '#69F0AE',
    systemPrompt: `You are Sara, a warm and outgoing person. You are genuinely curious about others and love making people feel comfortable.

PERSONALITY RULES:
- Use a warm, friendly, and encouraging tone at all times
- Use casual language with contractions (don't, I'm, you're, etc.)
- React with genuine enthusiasm to what the user shares
- If the user seems nervous or hesitant, gently encourage them
- Ask thoughtful follow-up questions to keep the conversation flowing
- Occasionally use light humor
- Give compliments when appropriate, but keep them genuine
- Use 1-3 sentences per response
- Never correct the user's English — respond naturally
- Show empathy and active listening
- Use expressions like "Oh wow!", "That's so cool!", "Tell me more!"`
  },
  {
    id: 'strict', name: 'Marcus', emoji: '😤', type: 'Strict',
    tone: 'Direct & Challenging',
    description: 'A no-nonsense professional with high standards. He challenges you to think clearly and communicate precisely.',
    traits: ['Demanding', 'Direct', 'Analytical', 'Impatient'],
    gradientStart: '#FF5252', gradientEnd: '#FF6B9D',
    systemPrompt: `You are Marcus, a senior professional with extremely high standards. You value precision, clarity, and confidence in communication.

PERSONALITY RULES:
- Be direct, concise, and slightly impatient
- Challenge weak, vague, or generic answers with pointed follow-up questions
- Show subtle skepticism — make the user prove their point
- If an answer is too long or unfocused, redirect them: "Get to the point."
- Occasionally interrupt with "But why?" or "That doesn't answer my question."
- Never praise unless the answer is genuinely exceptional
- Use short sentences, 1-2 per response
- Show that you have high expectations
- Never correct English — but react negatively to unclear communication
- If the user gives a good answer, acknowledge it briefly: "Fair point." or "Interesting."
- Maintain professional language but with an edge`
  },
  {
    id: 'neutral', name: 'Alex', emoji: '🤔', type: 'Neutral',
    tone: 'Professional & Balanced',
    description: 'A measured professional who maintains objectivity. Gives fair assessments and keeps conversations structured.',
    traits: ['Balanced', 'Professional', 'Structured', 'Fair'],
    gradientStart: '#6C63FF', gradientEnd: '#8B83FF',
    systemPrompt: `You are Alex, a professional colleague who is measured, fair, and methodical in conversations.

PERSONALITY RULES:
- Maintain a balanced, professional tone at all times
- Ask structured, thoughtful questions
- Give measured responses — neither overly positive nor critical
- Keep the conversation productive and on-topic
- Use moderate-length responses, 1-2 sentences
- Acknowledge good points objectively: "That's a valid perspective."
- Point out gaps in reasoning without being harsh: "Have you considered...?"
- Stay neutral in emotional tone
- Never correct English — respond naturally
- Use professional but accessible language
- If the conversation drifts, gently redirect to the topic`
  }
];

// ── Data: Scenarios ────────────────────────────────────────────
const SCENARIOS = [
  {
    id: 'job_interview', title: 'Job Interview', icon: '💼',
    description: 'Practice answering tough interview questions with confidence and clarity.',
    goal: 'Get hired by impressing the interviewer',
    difficulty: 'Hard',
    context: 'You are in a formal job interview at a top company. The interviewer is evaluating your communication skills, confidence, and ability to articulate your experience.',
    sampleTopics: ['Tell me about yourself', 'Why should we hire you?', 'Describe a challenge you overcame'],
  },
  {
    id: 'casual_chat', title: 'Casual Conversation', icon: '☕',
    description: 'Practice making small talk and building natural connections.',
    goal: 'Build rapport and keep the conversation flowing',
    difficulty: 'Easy',
    context: 'You are at a coffee shop and struck up a conversation with someone new. The atmosphere is relaxed and friendly.',
    sampleTopics: ['Hobbies', 'Travel', 'Weekend plans', 'Favorite movies'],
  },
  {
    id: 'business_meeting', title: 'Business Meeting', icon: '📊',
    description: 'Practice presenting ideas and negotiating professionally.',
    goal: 'Present your proposal and close the deal',
    difficulty: 'Medium',
    context: 'You are in a business meeting presenting a proposal to a potential client or partner. You need to be persuasive, clear, and professional.',
    sampleTopics: ['Project proposal', 'Budget discussion', 'Timeline negotiations'],
  }
];

// ── Opening Messages ───────────────────────────────────────────
const OPENINGS = {
  job_interview: {
    friendly: "Hi there! Welcome, please have a seat. I'm Sara, and I'll be conducting your interview today. Don't worry, just be yourself! So, tell me — what made you interested in this position?",
    strict: "Sit down. I'm Marcus. I have 15 minutes. Let's not waste time. Why should I hire you?",
    neutral: "Good morning. I'm Alex from the hiring team. Thank you for coming in today. Let's start — could you briefly walk me through your background?"
  },
  casual_chat: {
    friendly: "Hey! Is this seat taken? I love this coffee shop — I come here all the time! I'm Sara, by the way. What's your name?",
    strict: "Morning. I see you're sitting alone. Mind if I ask — what are you working on there?",
    neutral: "Hello. Nice place, isn't it? I'm Alex. Do you come here often?"
  },
  business_meeting: {
    friendly: "Great to finally meet in person! I'm Sara from the partnerships team. I've been really excited to hear about your proposal. Please, go ahead whenever you're ready!",
    strict: "Let's get started. I'm Marcus, VP of Operations. I've reviewed your preliminary materials. I have concerns. Convince me this is worth our investment.",
    neutral: "Good afternoon. I'm Alex, the project lead. Thank you for preparing this presentation. Please begin with an overview of your proposal."
  }
};

// ── App State ──────────────────────────────────────────────────
const state = {
  currentScreen: 'login',
  user: JSON.parse(localStorage.getItem('realtalk_user') || 'null'),
  selectedScenario: null,
  selectedCharacter: null,
  messages: [],        // { role, content }
  isThinking: false,
  error: null,
  sessionId: null,
  feedback: null,
  feedbackLoading: false,
  // Progress tracking
  progress: JSON.parse(localStorage.getItem('realtalk_progress') || '{"sessions":0,"streak":0,"fluency":0,"scenarios":{}}'),
};

// ── Router ─────────────────────────────────────────────────────
function navigate(screen) {
  state.currentScreen = screen;
  document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
  const el = document.getElementById(`screen-${screen}`);
  if (el) {
    el.classList.add('active');
    el.innerHTML = '';
    renderScreen(screen, el);
  }
  window.scrollTo(0, 0);
}

function renderScreen(screen, el) {
  switch (screen) {
    case 'login': renderLogin(el); break;
    case 'home': renderHome(el); break;
    case 'scenario': renderScenarioSelect(el); break;
    case 'character': renderCharacterSelect(el); break;
    case 'conversation': renderConversation(el); break;
    case 'feedback': renderFeedback(el); break;
  }
}

// ── Login Screen ───────────────────────────────────────────────
function renderLogin(el) {
  el.classList.add('login-screen');
  el.innerHTML = `
    <div class="login-logo">🗣️</div>
    <h1 class="login-title">RealTalk AI</h1>
    <p class="login-subtitle">Master Real Conversations</p>
    <input type="text" class="login-input" id="login-name" placeholder="Enter your name..." maxlength="30" value="${state.user?.name || ''}">
    <button class="btn-gradient" id="login-btn">
      <span>Get Started</span>
      <span>→</span>
    </button>
  `;

  const input = el.querySelector('#login-name');
  const btn = el.querySelector('#login-btn');

  const doLogin = () => {
    const name = input.value.trim();
    if (!name) { input.focus(); return; }
    state.user = { name, id: 'user_' + Date.now() };
    localStorage.setItem('realtalk_user', JSON.stringify(state.user));
    navigate('home');
  };

  btn.addEventListener('click', doLogin);
  input.addEventListener('keydown', e => { if (e.key === 'Enter') doLogin(); });
  input.focus();
}

// ── Home Screen ────────────────────────────────────────────────
function renderHome(el) {
  el.classList.remove('login-screen');
  const p = state.progress;

  el.innerHTML = `
    <div class="home-header">
      <div>
        <div class="home-welcome">Welcome back,</div>
        <div class="home-name">${state.user?.name || 'Learner'}</div>
      </div>
      <div class="home-avatar" id="avatar-btn">${(state.user?.name || 'U')[0].toUpperCase()}</div>
    </div>

    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-icon">📈</div>
        <div class="stat-value secondary">${p.fluency || 0}</div>
        <div class="stat-label">Fluency</div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">💬</div>
        <div class="stat-value primary">${p.sessions || 0}</div>
        <div class="stat-label">Sessions</div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">🔥</div>
        <div class="stat-value accent">${p.streak || 0}</div>
        <div class="stat-label">Streak</div>
      </div>
    </div>

    <div class="section">
      <div class="section-title">Start Practicing</div>
      <div class="section-subtitle">Choose a scenario to begin a conversation</div>
      <button class="btn-gradient" id="new-convo-btn">
        <span>➕</span>
        <span>New Conversation</span>
      </button>
      <div class="card-grid" style="margin-top:16px">
        ${SCENARIOS.map(s => `
          <div class="scenario-card" data-id="${s.id}">
            <div class="card-emoji">${s.icon}</div>
            <div class="card-title">${s.title}</div>
          </div>
        `).join('')}
      </div>
    </div>

    <div class="section">
      ${p.sessions === 0 ? `
        <div class="glass-card empty-state">
          <div class="empty-emoji">🎯</div>
          <div class="empty-title">No sessions yet</div>
          <div class="empty-text">Start your first conversation to begin tracking your progress!</div>
        </div>
      ` : `
        <div class="section-title">Your Progress</div>
        <div style="margin-top:16px">
          ${SCENARIOS.map(s => {
            const sp = p.scenarios[s.id];
            return `
              <div class="progress-card">
                <div class="progress-emoji">${s.icon}</div>
                <div class="progress-info">
                  <div class="progress-title">${s.title}</div>
                  <div class="progress-sessions">${sp?.completed || 0} sessions completed</div>
                </div>
                ${sp?.bestScore ? `<div class="progress-badge">Best: ${sp.bestScore}</div>` : ''}
              </div>
            `;
          }).join('')}
        </div>
      `}
    </div>
  `;

  el.querySelector('#new-convo-btn').addEventListener('click', () => navigate('scenario'));
  el.querySelector('#avatar-btn').addEventListener('click', showSignOutMenu);
  el.querySelectorAll('.scenario-card').forEach(card => {
    card.addEventListener('click', () => {
      state.selectedScenario = SCENARIOS.find(s => s.id === card.dataset.id);
      navigate('character');
    });
  });
}

// ── Scenario Selection ─────────────────────────────────────────
function renderScenarioSelect(el) {
  el.classList.remove('login-screen');
  el.innerHTML = `
    <div class="chat-topbar">
      <button class="chat-back" id="scenario-back">←</button>
      <div class="chat-info">
        <div class="chat-scenario">Choose a Scenario</div>
        <div class="chat-character">Pick a situation to practice</div>
      </div>
    </div>
    <div class="section">
      <div class="card-grid vertical">
        ${SCENARIOS.map(s => `
          <div class="scenario-card" data-id="${s.id}" style="text-align:left;display:flex;align-items:flex-start;gap:16px;">
            <div class="card-emoji" style="margin:0;flex-shrink:0">${s.icon}</div>
            <div style="flex:1">
              <div class="card-title">${s.title}</div>
              <div class="card-desc" style="margin-top:4px">${s.description}</div>
              <span class="difficulty-badge ${s.difficulty.toLowerCase()}">${s.difficulty}</span>
            </div>
          </div>
        `).join('')}
      </div>
    </div>
  `;

  el.querySelector('#scenario-back').addEventListener('click', () => navigate('home'));
  el.querySelectorAll('.scenario-card').forEach(card => {
    card.addEventListener('click', () => {
      state.selectedScenario = SCENARIOS.find(s => s.id === card.dataset.id);
      navigate('character');
    });
  });
}

// ── Character Selection ────────────────────────────────────────
function renderCharacterSelect(el) {
  el.classList.remove('login-screen');
  el.innerHTML = `
    <div class="chat-topbar">
      <button class="chat-back" id="char-back">←</button>
      <div class="chat-info">
        <div class="chat-scenario">${state.selectedScenario?.icon || ''} ${state.selectedScenario?.title || 'Select Character'}</div>
        <div class="chat-character">Choose your conversation partner</div>
      </div>
    </div>
    <div class="section">
      <div class="card-grid vertical">
        ${CHARACTERS.map(c => `
          <div class="character-card" data-id="${c.id}">
            <div class="card-emoji">${c.emoji}</div>
            <div class="character-info">
              <div class="card-title">${c.name} — ${c.type}</div>
              <div class="card-desc">${c.description}</div>
              <div class="character-traits">
                ${c.traits.map(t => `<span class="trait-tag">${t}</span>`).join('')}
              </div>
            </div>
          </div>
        `).join('')}
      </div>
    </div>
  `;

  el.querySelector('#char-back').addEventListener('click', () => navigate('scenario'));
  el.querySelectorAll('.character-card').forEach(card => {
    card.addEventListener('click', () => {
      state.selectedCharacter = CHARACTERS.find(c => c.id === card.dataset.id);
      startConversation();
    });
  });
}

// ── Start Conversation ─────────────────────────────────────────
function startConversation() {
  const scenario = state.selectedScenario;
  const character = state.selectedCharacter;

  // Build system prompt
  const systemPrompt = `${character.systemPrompt}

CURRENT SCENARIO: ${scenario.title}
SCENARIO CONTEXT: ${scenario.context}
USER'S GOAL: ${scenario.goal}

ADDITIONAL INSTRUCTIONS:
- You are in a ${scenario.title.toLowerCase()} scenario
- Adapt your difficulty based on the user's responses
- If the user gives short/simple responses, keep your questions accessible
- If the user communicates well, increase the challenge
- Keep the conversation natural and evolving
- Never break character or reveal you are an AI
- Maximum 1-3 sentences per response
- Drive the conversation forward with each response`;

  // Get opening message
  const opening = OPENINGS[scenario.id]?.[character.id] || "Hello! Let's start our conversation.";

  state.messages = [
    { role: 'system', content: systemPrompt },
    { role: 'assistant', content: opening },
  ];
  state.sessionId = 'session_' + Date.now();
  state.isThinking = false;
  state.error = null;

  navigate('conversation');
}

// ── Conversation Screen ────────────────────────────────────────
function renderConversation(el) {
  el.classList.remove('login-screen');
  const scenario = state.selectedScenario;
  const character = state.selectedCharacter;
  const displayMessages = state.messages.filter(m => m.role !== 'system');
  const userMsgCount = state.messages.filter(m => m.role === 'user').length;

  el.innerHTML = `
    <div class="chat-topbar">
      <button class="chat-back" id="convo-back">←</button>
      <div class="chat-info">
        <div class="chat-scenario">${scenario?.icon || ''} ${scenario?.title || ''}</div>
        <div class="chat-character">with ${character?.name || 'AI'} (${character?.type || ''})</div>
      </div>
      <div class="chat-msg-count">${userMsgCount} msgs</div>
      <button class="chat-end-btn ${userMsgCount >= 2 ? 'active' : ''}" id="end-btn">End</button>
    </div>

    <div class="chat-messages" id="chat-messages">
      ${displayMessages.map(m => renderBubble(m, character)).join('')}
      ${state.isThinking ? renderTypingIndicator(character) : ''}
    </div>

    ${state.error ? `<div class="error-banner" id="error-banner">⚠️ ${state.error}</div>` : ''}

    <div class="chat-input-area">
      <div class="chat-input-row">
        <input type="text" class="chat-input" id="chat-input" placeholder="Type your message..." ${state.isThinking ? 'disabled' : ''}>
        <button class="chat-send-btn" id="send-btn" ${state.isThinking ? 'disabled' : ''}>➤</button>
      </div>
    </div>
  `;

  // Scroll to bottom
  const messagesEl = el.querySelector('#chat-messages');
  messagesEl.scrollTop = messagesEl.scrollHeight;

  // Event listeners
  const input = el.querySelector('#chat-input');
  const sendBtn = el.querySelector('#send-btn');
  const endBtn = el.querySelector('#end-btn');
  const backBtn = el.querySelector('#convo-back');

  const doSend = () => {
    const text = input.value.trim();
    if (!text || state.isThinking) return;
    input.value = '';
    sendMessage(text);
  };

  sendBtn.addEventListener('click', doSend);
  input.addEventListener('keydown', e => { if (e.key === 'Enter') doSend(); });
  if (!state.isThinking) input.focus();

  endBtn.addEventListener('click', () => {
    if (userMsgCount < 2) { navigate('home'); return; }
    showEndDialog();
  });

  backBtn.addEventListener('click', () => {
    if (userMsgCount < 2) { navigate('home'); return; }
    showEndDialog();
  });

  const errorBanner = el.querySelector('#error-banner');
  if (errorBanner) {
    errorBanner.addEventListener('click', () => {
      state.error = null;
      navigate('conversation');
    });
  }
}

function renderBubble(msg, character) {
  if (msg.role === 'user') {
    return `<div class="bubble-wrapper user"><div class="bubble user">${escapeHtml(msg.content)}</div></div>`;
  }
  return `
    <div class="bubble-wrapper ai">
      <div class="bubble-avatar">${character?.emoji || '🤖'}</div>
      <div class="bubble ai">${escapeHtml(msg.content)}</div>
    </div>`;
}

function renderTypingIndicator(character) {
  return `
    <div class="typing-indicator">
      <div class="bubble-avatar">${character?.emoji || '🤖'}</div>
      <div class="typing-dots">
        <div class="typing-dot"></div>
        <div class="typing-dot"></div>
        <div class="typing-dot"></div>
      </div>
      <span class="typing-label">${character?.name || 'AI'} is thinking...</span>
    </div>`;
}

function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

// ── Send Message ───────────────────────────────────────────────
async function sendMessage(text) {
  // Add user message
  state.messages.push({ role: 'user', content: text });
  state.isThinking = true;
  state.error = null;
  navigate('conversation');

  try {
    const response = await fetch('/api/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        messages: state.messages.map(m => ({ role: m.role, content: m.content })),
      }),
    });

    if (!response.ok) {
      const err = await response.json().catch(() => ({}));
      throw new Error(err.error || `API error: ${response.status}`);
    }

    const data = await response.json();
    state.messages.push({ role: 'assistant', content: data.content });
    state.isThinking = false;
    navigate('conversation');
  } catch (error) {
    state.isThinking = false;
    state.error = error.message || 'Failed to get response';
    navigate('conversation');
  }
}

// ── End Session Dialog ─────────────────────────────────────────
function showEndDialog() {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML = `
    <div class="modal-card">
      <div class="modal-title">End Conversation?</div>
      <div class="modal-text">Would you like to end this session and get your feedback?</div>
      <div class="modal-actions">
        <button class="modal-btn secondary" id="modal-cancel">Continue</button>
        <button class="modal-btn primary" id="modal-confirm">Get Feedback</button>
      </div>
    </div>
  `;
  document.body.appendChild(overlay);

  overlay.querySelector('#modal-cancel').addEventListener('click', () => overlay.remove());
  overlay.querySelector('#modal-confirm').addEventListener('click', () => {
    overlay.remove();
    endSession();
  });
  overlay.addEventListener('click', e => { if (e.target === overlay) overlay.remove(); });
}

function showSignOutMenu() {
  const overlay = document.createElement('div');
  overlay.className = 'modal-overlay';
  overlay.innerHTML = `
    <div class="modal-card">
      <div class="modal-title">Settings</div>
      <div class="modal-text">Signed in as ${state.user?.name || 'User'}</div>
      <div class="modal-actions">
        <button class="modal-btn secondary" id="modal-cancel">Close</button>
        <button class="modal-btn primary" id="modal-signout" style="background:var(--error)">Sign Out</button>
      </div>
    </div>
  `;
  document.body.appendChild(overlay);

  overlay.querySelector('#modal-cancel').addEventListener('click', () => overlay.remove());
  overlay.querySelector('#modal-signout').addEventListener('click', () => {
    localStorage.removeItem('realtalk_user');
    state.user = null;
    overlay.remove();
    navigate('login');
  });
  overlay.addEventListener('click', e => { if (e.target === overlay) overlay.remove(); });
}

// ── End Session & Get Feedback ─────────────────────────────────
async function endSession() {
  state.feedbackLoading = true;
  state.feedback = null;
  navigate('feedback');

  try {
    const response = await fetch('/api/feedback', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        messages: state.messages.map(m => ({ role: m.role, content: m.content })),
        scenarioContext: state.selectedScenario?.context || '',
        characterName: state.selectedCharacter?.name || 'AI',
        sessionId: state.sessionId,
      }),
    });

    if (!response.ok) {
      throw new Error(`Feedback API error: ${response.status}`);
    }

    state.feedback = await response.json();
    state.feedbackLoading = false;

    // Update progress
    updateProgress(state.feedback);

    navigate('feedback');
  } catch (error) {
    state.feedbackLoading = false;
    state.feedback = {
      error: error.message || 'Failed to generate feedback',
      confidenceScore: 50,
      fluencyScore: 50,
      grammarCorrections: [],
      improvedResponses: [],
      strengths: ['Completed the conversation'],
      areasToImprove: ['Keep practicing for more detailed feedback'],
      overallFeedback: 'Unable to generate detailed feedback. Please try again.',
    };
    navigate('feedback');
  }
}

function updateProgress(feedback) {
  const p = state.progress;
  p.sessions = (p.sessions || 0) + 1;
  p.fluency = feedback.fluencyScore || p.fluency;
  p.streak = (p.streak || 0) + 1;

  const scenarioId = state.selectedScenario?.id;
  if (scenarioId) {
    if (!p.scenarios[scenarioId]) p.scenarios[scenarioId] = { completed: 0, bestScore: 0 };
    p.scenarios[scenarioId].completed += 1;
    const avg = Math.round((feedback.confidenceScore + feedback.fluencyScore) / 2);
    if (avg > p.scenarios[scenarioId].bestScore) p.scenarios[scenarioId].bestScore = avg;
  }

  localStorage.setItem('realtalk_progress', JSON.stringify(p));
}

// ── Feedback Screen ────────────────────────────────────────────
function renderFeedback(el) {
  el.classList.remove('login-screen');
  el.classList.add('feedback-screen');

  if (state.feedbackLoading) {
    el.innerHTML = `
      <div class="loading-container">
        <div class="loading-spinner">🧠</div>
        <div class="loading-title">Analyzing your conversation...</div>
        <div class="loading-subtitle">This may take a few seconds</div>
        <div class="loading-bar"><div class="loading-bar-fill"></div></div>
      </div>
    `;
    return;
  }

  const fb = state.feedback;
  if (!fb) return;

  const circumference = 2 * Math.PI * 44; // r=44
  const confOffset = circumference - (circumference * fb.confidenceScore / 100);
  const fluOffset = circumference - (circumference * fb.fluencyScore / 100);
  const scoreClass = (v) => v >= 70 ? 'high' : v >= 40 ? 'mid' : 'low';

  el.innerHTML = `
    <div class="feedback-header">
      <div class="feedback-emoji">🎉</div>
      <h1 class="feedback-title">Session Complete!</h1>
      <p class="feedback-subtitle">Here's how you did</p>
    </div>

    <div class="scores-row">
      <div class="score-gauge">
        <div class="gauge-circle">
          <svg viewBox="0 0 100 100">
            <circle class="gauge-bg" cx="50" cy="50" r="44"/>
            <circle class="gauge-fill confidence" cx="50" cy="50" r="44"
              stroke-dasharray="${circumference}"
              stroke-dashoffset="${confOffset}"/>
          </svg>
          <span class="gauge-value ${scoreClass(fb.confidenceScore)}">${fb.confidenceScore}</span>
        </div>
        <div class="gauge-label">Confidence</div>
      </div>
      <div class="score-gauge">
        <div class="gauge-circle">
          <svg viewBox="0 0 100 100">
            <circle class="gauge-bg" cx="50" cy="50" r="44"/>
            <circle class="gauge-fill fluency" cx="50" cy="50" r="44"
              stroke-dasharray="${circumference}"
              stroke-dashoffset="${fluOffset}"/>
          </svg>
          <span class="gauge-value ${scoreClass(fb.fluencyScore)}">${fb.fluencyScore}</span>
        </div>
        <div class="gauge-label">Fluency</div>
      </div>
    </div>

    <div class="ai-coach-card">
      <div class="ai-coach-header">✨ AI Coach Feedback</div>
      <div class="ai-coach-text">${escapeHtml(fb.overallFeedback || '')}</div>
    </div>

    ${fb.strengths?.length ? `
      <div class="feedback-section">
        <div class="feedback-section-header">
          <span class="feedback-section-icon">⭐</span>
          <span class="feedback-section-title">Strengths</span>
        </div>
        ${fb.strengths.map(s => `
          <div class="feedback-item">
            <span class="feedback-item-icon" style="color:var(--success)">✓</span>
            <span class="feedback-item-text">${escapeHtml(s)}</span>
          </div>
        `).join('')}
      </div>
    ` : ''}

    ${fb.areasToImprove?.length ? `
      <div class="feedback-section">
        <div class="feedback-section-header">
          <span class="feedback-section-icon">📈</span>
          <span class="feedback-section-title">Areas to Improve</span>
        </div>
        ${fb.areasToImprove.map(a => `
          <div class="feedback-item">
            <span class="feedback-item-icon" style="color:var(--warning)">ℹ</span>
            <span class="feedback-item-text">${escapeHtml(a)}</span>
          </div>
        `).join('')}
      </div>
    ` : ''}

    ${fb.grammarCorrections?.length ? `
      <div class="feedback-section">
        <div class="feedback-section-header">
          <span class="feedback-section-icon">✏️</span>
          <span class="feedback-section-title">Grammar Corrections</span>
        </div>
        ${fb.grammarCorrections.map(c => `
          <div class="correction-card">
            <div class="correction-original">"${escapeHtml(c.original || '')}"</div>
            <div class="correction-fixed">"${escapeHtml(c.corrected || '')}"</div>
            <div class="correction-why">${escapeHtml(c.explanation || '')}</div>
          </div>
        `).join('')}
      </div>
    ` : ''}

    ${fb.improvedResponses?.length ? `
      <div class="feedback-section">
        <div class="feedback-section-header">
          <span class="feedback-section-icon">💡</span>
          <span class="feedback-section-title">Better Ways to Respond</span>
        </div>
        ${fb.improvedResponses.map(s => `
          <div class="suggestion-card">
            <div class="suggestion-said">You said: "${escapeHtml(s.userSaid || '')}"</div>
            <div class="suggestion-better">Better: "${escapeHtml(s.betterWay || '')}"</div>
            <div class="suggestion-why">${escapeHtml(s.why || '')}</div>
          </div>
        `).join('')}
      </div>
    ` : ''}

    <div class="feedback-actions">
      <button class="btn-gradient" id="practice-again">
        <span>🔄</span>
        <span>Practice Again</span>
      </button>
      <button class="btn-outline" id="back-home">
        <span>🏠</span>
        <span>Back to Home</span>
      </button>
    </div>
  `;

  // Animate score gauges after render
  requestAnimationFrame(() => {
    el.querySelectorAll('.gauge-fill').forEach(circle => {
      const target = circle.getAttribute('stroke-dashoffset');
      circle.style.strokeDashoffset = circumference;
      requestAnimationFrame(() => { circle.style.strokeDashoffset = target; });
    });
  });

  el.querySelector('#practice-again').addEventListener('click', () => {
    state.feedback = null;
    navigate('character');
  });

  el.querySelector('#back-home').addEventListener('click', () => {
    state.feedback = null;
    state.selectedScenario = null;
    state.selectedCharacter = null;
    navigate('home');
  });
}

// ── Init ───────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  if (state.user) {
    navigate('home');
  } else {
    navigate('login');
  }
});
