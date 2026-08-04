---
name: smart-dispatch
description: Automatically routes tasks to optimal Claude models
  (opus/sonnet/haiku) based on complexity. Use when implementing
  features, fixing bugs, or any multi-step development work.
---

# Smart Model Dispatch

## Model Routing Rules

### opus — Complex reasoning & architecture
- Architecture planning and design
- Complex business logic implementation
- Feature planning and requirement analysis

### sonnet — Standard implementation
- Business logic (use cases, repositories, stores)
- Screen/component implementation with logic
- Firebase/API integration

### haiku — Fast, mechanical tasks
- Generating .styles.ts files
- Writing i18n translation files
- Creating boilerplate and mocks
- Writing unit tests
```markdown

A skill inclui regras claras de quando usar cada modelo e exemplos de dispatch paralelo:

```markdown
Exemplo: "Implementa a feature Watchlist"

1. [opus]   Planeja arquitetura
2. [sonnet] Implementa domain + data layers
3. [sonnet] Implementa screen com ViewModel
4. [haiku]  Gera .styles.ts, i18n, mocks
5. [haiku]  Escreve testes unitários

