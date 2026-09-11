# N-OS AI Hub (`nos ai`)

Installation centralisée des assistants IA pour le développement.

```bash
nos ai list
nos ai install claude gemini ollama
nos ai remove aider
nos ai update
```

| ID | Assistant | Méthode | Première utilisation |
|---|---|---|---|
| `claude` | Claude Code (Anthropic) | `npm -g @anthropic-ai/claude-code` | `claude` (connexion au compte) |
| `gemini` | Gemini CLI (Google) | `npm -g @google/gemini-cli` | `gemini` |
| `copilot` | GitHub Copilot CLI | `npm -g @github/copilot` | `copilot` |
| `opencode` | OpenCode | `npm -g opencode-ai` | `opencode` |
| `aider` | Aider | `pipx install aider-chat` | clé API puis `aider` |
| `ollama` | Ollama (modèles locaux) | script officiel `ollama.com/install.sh` | `ollama pull llama3.2` |
| `continue` | Continue (extension VS Code) | `code --install-extension Continue.continue` | dans VS Code |

## Préfixe npm utilisateur

Si le préfixe npm est `/usr` ou `/usr/local` (installation système), `nos ai` bascule sur `~/.nos/npm-global` et l'ajoute au PATH via `~/.nos/env.sh`, pour éviter `sudo npm -g`.

## ISO

L'image préinstalle Claude Code, Gemini CLI et OpenCode (hook `0200-nos-devtools`). Ollama, Aider, Continue et Copilot s'installent à la demande.

## Modèles locaux et connexions lentes

Ollama fonctionne hors ligne une fois un modèle téléchargé. Modèles conseillés selon la RAM : `qwen2.5-coder:1.5b` (4 Go), `llama3.2` (8 Go), `qwen2.5-coder:7b` (16 Go).
