# Calorie Tracker Mobile 🍎

Um aplicativo Flutter nativo para monitoramento de calorias e macronutrientes, turbinado com Inteligência Artificial (Gemini).

## ✨ Funcionalidades

- **Análise com IA**: Tire uma foto do seu prato ou descreva sua refeição, e a IA estima calorias, proteínas, carboidratos e gorduras.
- **Dashboard Diário**: Acompanhe sua meta de calorias e a distribuição de macros em tempo real.
- **Cálculo Automático de Metas**: O app calcula sua Taxa de Metabolismo Basal (TDEE) com base no seu perfil.
- **Histórico Inteligente**: Reutilize refeições passadas rapidamente através da busca no histórico.

---

## 🚀 Segurança e Build (Portfólio)

Este projeto foi desenvolvido com foco em **segurança da informação** e **boas práticas de portfólio**. A chave da API do Gemini nunca é exposta no código-fonte ou no GitHub.

### Configuração da Chave
1. Crie um arquivo chamado `keys.json` na raiz do projeto.
2. Adicione sua chave seguindo este modelo:
   ```json
   {
     "GEMINI_API_KEY": "SUA_CHAVE_AQUI"
   }
   ```

### Como Rodar / Gerar APK Seguro
Para que o app reconheça a chave e proteja o código contra engenharia reversa:

**Desenvolvimento:**
```bash
flutter run --dart-define-from-file=keys.json
```

**Gerar APK para Portfólio (Obfuscado):**
```bash
flutter build apk --obfuscate --split-debug-info=build/app/outputs/symbols --dart-define-from-file=keys.json
```

> [!IMPORTANT]
> O uso do parâmetro `--obfuscate` embaralha o código binário, protegendo a chave da API embutida no APK final.

---

## 🛠️ Tecnologias
- **Flutter & Dart**
- **Provider** (Gerenciamento de Estado)
- **SharedPreferences** (Persistência Local)
- **google_generative_ai** (Integração com Gemini)
