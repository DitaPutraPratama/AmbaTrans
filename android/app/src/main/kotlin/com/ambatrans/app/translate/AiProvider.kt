package com.ambatrans.app.translate

/**
 * AI services with an OpenAI-compatible chat API (ADR-024). [id] is the stored `translate_engine` value;
 * [defaultModel] applies until the user enters another model ID.
 */
// ponytail: default model IDs go stale as providers retire models; the user can type a new one in Settings.
enum class AiProvider(val id: String, val url: String, val defaultModel: String) {
    GROQ("groq", "https://api.groq.com/openai/v1/chat/completions", "llama-3.3-70b-versatile"),
    GEMINI(
        "gemini",
        "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions",
        "gemini-3.5-flash-lite",
    ),
    CEREBRAS("cerebras", "https://api.cerebras.ai/v1/chat/completions", "gpt-oss-120b"),
    MISTRAL("mistral", "https://api.mistral.ai/v1/chat/completions", "mistral-small-latest"),
    OPENAI("openai", "https://api.openai.com/v1/chat/completions", "gpt-6-luna"),
    DEEPSEEK("deepseek", "https://api.deepseek.com/chat/completions", "deepseek-flash"),
    ;

    companion object {
        fun of(id: String): AiProvider? = entries.firstOrNull { it.id == id }
    }
}
