import '../../../../core/strings.dart';
import '../../application/settings_controller.dart';

enum EngineGroup { offline, free, paid }

/// Display data for each engine: name, short note, group and help links.
extension EngineInfo on TranslationEngine {
  String get label => switch (this) {
    TranslationEngine.mlkit => 'ML Kit',
    TranslationEngine.deepl => 'DeepL',
    TranslationEngine.groq => 'Groq',
    TranslationEngine.gemini => 'Google Gemini',
    TranslationEngine.cerebras => 'Cerebras',
    TranslationEngine.mistral => 'Mistral',
    TranslationEngine.openai => 'OpenAI',
    TranslationEngine.deepseek => 'DeepSeek',
  };

  String get note => switch (this) {
    TranslationEngine.mlkit => Strings.engineMlkitBody,
    TranslationEngine.deepl => Strings.engineDeeplBody,
    TranslationEngine.groq => Strings.engineGroqBody,
    TranslationEngine.gemini => Strings.engineGeminiBody,
    TranslationEngine.cerebras => Strings.engineCerebrasBody,
    TranslationEngine.mistral => Strings.engineMistralBody,
    TranslationEngine.openai => Strings.engineOpenaiBody,
    TranslationEngine.deepseek => Strings.engineDeepseekBody,
  };

  EngineGroup get group => switch (this) {
    TranslationEngine.mlkit => EngineGroup.offline,
    TranslationEngine.openai || TranslationEngine.deepseek => EngineGroup.paid,
    _ => EngineGroup.free,
  };

  String? get keysUrl => switch (this) {
    TranslationEngine.mlkit => null,
    TranslationEngine.deepl => 'https://www.deepl.com/your-account/keys',
    TranslationEngine.groq => 'https://console.groq.com/keys',
    TranslationEngine.gemini => 'https://aistudio.google.com/apikey',
    TranslationEngine.cerebras => 'https://cloud.cerebras.ai',
    TranslationEngine.mistral => 'https://console.mistral.ai/api-keys',
    TranslationEngine.openai => 'https://platform.openai.com/api-keys',
    TranslationEngine.deepseek => 'https://platform.deepseek.com/api_keys',
  };

  String? get modelsUrl => switch (this) {
    TranslationEngine.mlkit || TranslationEngine.deepl => null,
    TranslationEngine.groq => 'https://console.groq.com/docs/models',
    TranslationEngine.gemini => 'https://ai.google.dev/gemini-api/docs/models',
    TranslationEngine.cerebras =>
      'https://inference-docs.cerebras.ai/models/overview',
    TranslationEngine.mistral =>
      'https://docs.mistral.ai/getting-started/models/',
    TranslationEngine.openai => 'https://developers.openai.com/api/docs/models',
    TranslationEngine.deepseek =>
      'https://api-docs.deepseek.com/quick_start/pricing',
  };
}

extension EngineGroupTitle on EngineGroup {
  String get title => switch (this) {
    EngineGroup.offline => Strings.groupOffline,
    EngineGroup.free => Strings.groupFree,
    EngineGroup.paid => Strings.groupPaid,
  };
}
