---
name: create-spring-bdd
description: "Create Cucumber/Gherkin BDD tests (feature files + step definitions) as Spring Boot integration tests following the team's definitive conventions. Use when the user asks to create a BDD test, write a Cucumber test, 'escreva um teste BDD', 'crie um cenário', add a feature file, or wants scenario-driven coverage for a use case (create/update/delete/view resources)."
---

# Spring Boot BDD (Cucumber) Test Conventions

**Objective:** Standardize the creation and maintenance of Behavior-Driven Development (BDD) tests in Spring Boot applications using Cucumber + Gherkin, ensuring consistent style, readability, and maintainability across feature files and step definitions.

**Default style:** BDD tests are **always integration tests**. They load the full Spring context via `@CucumberContextConfiguration` + `@SpringBootTest`, run against the **real concrete repository implementations** (`*RepositoryImpl`), and drive the real application use cases. Never use Mockito, never slice the context (`@WebMvcTest`, `@DataJpaTest`, etc.), never mock a repository or use case.

**Database:** Prefer **Testcontainers** for the disposable test database. If the target repository's test suite already runs against another database (e.g., an in-memory H2 configured in `src/test/resources/application.properties`), **mirror the repo** — repo conventions win. See Section 9.

**Fallback clause:** The rules below are the team standard. If the target repository's existing BDD suite visibly deviates from them (package layout, step names, factory naming `makeX`/`persisteX`, `*Impl` vs interface), **mirror the repo** — read the existing `bdd/` package first and copy its style. Repo conventions win over this guide.

**Standard Stack:**
- Cucumber JUnit Platform — `cucumber-java`, `cucumber-spring`, `cucumber-junit-platform-engine`, `junit-platform-suite`
- Full Spring context (`@CucumberContextConfiguration` + `@SpringBootTest`, real repositories, no Mockito)
- Testcontainers (preferred) for the database
- AssertJ — `assertThat` for all state/value assertions
- `com.github.javafaker.Faker` in `*Factory` classes for realistic fake data
- Gherkin in **Portuguese** (`# language: pt`), step annotations from `io.cucumber.java.pt.*`

---

## 1. Package Layout

BDD tests live under `src/test/resources/features/` (feature files) and a `bdd/` package under `src/test/java` (runner, config, hooks, shared state, step definitions). Glue is declared at the `bdd/` root; Cucumber scans it **recursively**, so subpackages like `steps` are automatically picked up.

```
src/test/resources/
├── features/                     # Gherkin feature files (one per functional area)
│   ├── criar_usuario.feature
│   ├── criar_topico.feature
│   └── ...
├── application.properties         # test datasource config (repo-specific)
└── junit-platform.properties     # cucumber JUnit Platform tuning

src/test/java/<base>/
└── bdd/
    ├── CucumberRunnerTest.java   # @Suite runner that bootstraps Cucumber
    ├── SpringCucumberConfig.java # @CucumberContextConfiguration + @SpringBootTest
    ├── Hooks.java                # Cucumber @Before cleanDatabase (FK order)
    ├── TestContext.java          # @Component @ScenarioScope shared step state
    └── steps/                    # step definition classes
        ├── UserSteps.java        # @Dado/@Quando grouped by domain
        ├── TopicSteps.java
        ├── AnswerSteps.java
        └── AssertionSteps.java   # all @Então/@E assertions + exception mapping
```

## 2. Boilerplate Files

### 2.1 `CucumberRunnerTest.java`

```java
package br.alura.ForumHub.bdd;

import static io.cucumber.junit.platform.engine.Constants.GLUE_PROPERTY_NAME;
import static io.cucumber.junit.platform.engine.Constants.PLUGIN_PROPERTY_NAME;

import org.junit.platform.suite.api.ConfigurationParameter;
import org.junit.platform.suite.api.IncludeEngines;
import org.junit.platform.suite.api.SelectClasspathResource;
import org.junit.platform.suite.api.Suite;

@Suite
@IncludeEngines("cucumber")
@SelectClasspathResource("features")
@ConfigurationParameter(key = GLUE_PROPERTY_NAME, value = "br.alura.ForumHub.bdd")
@ConfigurationParameter(key = PLUGIN_PROPERTY_NAME, value = "pretty, html:target/cucumber-reports.html")
public class CucumberRunnerTest {
}
```

- `@SelectClasspathResource("features")` points at `src/test/resources/features/`.
- `GLUE_PROPERTY_NAME` points at the **`bdd/` package root** (not the `steps` subpackage) — recursive scanning picks up `Hooks`, `SpringCucumberConfig`, and everything in `steps`.
- Adjust the package in `GLUE_PROPERTY_NAME` and the class package to the target repo's base (`<base>.bdd`).

### 2.2 `SpringCucumberConfig.java`

```java
package br.alura.ForumHub.bdd;

import org.springframework.boot.test.context.SpringBootTest;

import io.cucumber.spring.CucumberContextConfiguration;

@CucumberContextConfiguration
@SpringBootTest
public class SpringCucumberConfig {
}
```

This is the single class Cucumber hands the Spring context to. It must be inside the glue root. Every BDD test runs against this full application context — real security, use cases, repositories, and factories.

### 2.3 `junit-platform.properties` (in `src/test/resources`)

```properties
cucumber.publish.quiet=true
cucumber.junit-platform.naming-strategy=long
```

### 2.4 Maven Dependencies

```xml
<dependency>
  <groupId>io.cucumber</groupId>
  <artifactId>cucumber-java</artifactId>
  <version>7.21.1</version>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>io.cucumber</groupId>
  <artifactId>cucumber-spring</artifactId>
  <version>7.21.1</version>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>io.cucumber</groupId>
  <artifactId>cucumber-junit-platform-engine</artifactId>
  <version>7.21.1</version>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>org.junit.platform</groupId>
  <artifactId>junit-platform-suite</artifactId>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>com.github.javafaker</groupId>
  <artifactId>javafaker</artifactId>
  <version>1.0.2</version>
</dependency>
```

## 3. Feature Files

### 3.1 Language and Header

Feature files are written in **Portuguese**. The first line is always the language pragma `# language: pt`. One file per functional area, named in **snake_case** that mirrors the `Funcionalidade:` label.

```gherkin
# language: pt
Funcionalidade: Criação de respostas

  Cenário: criar resposta com sucesso
    Dado que existe um usuário ativo cadastrado
    E que esse usuário possui um tópico ativo cadastrado
    Quando eu criar uma resposta com conteúdo "Minha resposta para o tópico" para o tópico do usuário cadastrado
    Então uma resposta com o conteúdo "Minha resposta para o tópico" deve ser criada para o tópico
```

**File-name ↔ `Funcionalidade` mapping (examples):**
- `criar_usuario.feature` → `Funcionalidade: Cadastro de usuário`
- `criar_topico.feature` → `Funcionalidade: Criação de tópicos`
- `atualizar_topico.feature` → `Funcionalidade: Atualização de tópicos`
- `deletar_topico.feature` → `Funcionalidade: Exclusão de tópicos`
- `visualizar_topicos.feature` → `Funcionalidade: Visualização de Tópicos`
- `criar_resposta.feature` → `Funcionalidade: Criação de respostas`

### 3.2 Scenario Coverage

Write one `Cenário:` per behavior: the **happy path first**, then **every failure branch** (resource not found, inactive author/topic, not the owner, duplicate unique field). Name scenarios in lowercase, descriptive Portuguese.

```gherkin
  Cenário: rejeitar a criação quando o autor está inativo
    Dado que existe um usuário inativo cadastrado
    E que esse usuário possui um tópico ativo cadastrado
    Quando eu criar uma resposta com conteúdo "Minha resposta" para o tópico do usuário cadastrado
    Então a operação deve falhar com a exceção "InactiveResourceException"
    E nenhuma resposta deve ser criada
```

- `Dado`/`E` build preconditions (persisted state via factories).
- `Quando` performs a single action (drives a use case).
- `Então`/`E` assert outcomes — failures are expressed with the reusable generic steps
  `Então a operação deve falhar com a exceção "..."` and `E a mensagem da exceção deve conter "..."`.
- Failure scenarios always end with a **negative side-effect assertion** (`E nenhuma resposta deve ser criada`) so the database state is verified too.
- Reuse step sentences verbatim across files (e.g., `Dado que existe um usuário ativo cadastrado` appears in every feature) — this is by design; step definitions are shared.

## 4. TestContext — Shared State Between Steps

Steps cannot easily pass values to each other as method returns; all state exchanged across steps lives in a `@Component @ScenarioScope` class. Cucumber + Spring keep one instance **per scenario** (`@ScenarioScope`), so it resets automatically between scenarios. Fields are `public` and hold both domain objects and the outcome of the last action.

```java
package br.alura.ForumHub.bdd;

import java.util.List;

import org.springframework.stereotype.Component;

import br.alura.ForumHub.domain.entity.Answer;
import br.alura.ForumHub.domain.entity.Topic;
import br.alura.ForumHub.domain.entity.User;
import br.alura.ForumHub.domain.valueobject.TopicWithAnswers;
import io.cucumber.spring.ScenarioScope;

@Component
@ScenarioScope
public class TestContext {

  public User author;
  public User otherUser;
  public Topic topic;
  public String originalTopicContent;
  public String previousTopicSlug;
  public String plainPassword;
  public User createdUser;
  public Topic createdTopic;
  public Answer createdAnswer;
  public RuntimeException exception;
  public List<Answer> answers;
  public TopicWithAnswers topicWithAnswers;
}
```

Rules:
- Add a `public` field for every piece of state a scenario needs to carry across steps. Keep the repo's names (`author`, `topic`, `createdUser`, `exception`, ...).
- `exception` is the standard slot for capturing use-case failures (see Section 6.2).

## 5. Hooks — Database Cleanup

A Cucumber `@Before` hook guarantees every scenario starts from a clean database. It uses the **concrete `*RepositoryImpl` implementations** so it can call impl-only helpers like `deleteAll()`.

```java
package br.alura.ForumHub.bdd;

import org.springframework.beans.factory.annotation.Autowired;

import br.alura.ForumHub.infra.persistence.repository.AnswerRepositoryImpl;
import br.alura.ForumHub.infra.persistence.repository.TopicRepositoryImpl;
import br.alura.ForumHub.infra.persistence.repository.UserRepositoryImpl;
import io.cucumber.java.Before;

public class Hooks {

  @Autowired
  private AnswerRepositoryImpl answerRepository;

  @Autowired
  private TopicRepositoryImpl topicRepository;

  @Autowired
  private UserRepositoryImpl userRepository;

  @Autowired
  private TestContext state;

  @Before
  public void cleanDatabase() {
    answerRepository.deleteAll();
    topicRepository.deleteAll();
    userRepository.deleteAll();
  }
}
```

- Use `io.cucumber.java.Before` (Cucumber's hook), **not** JUnit's.
- Delete in **child-to-parent foreign-key order** (answers → topics → users).
- Only delete what the suite touches.
- Keep the method name the repo uses (`cleanDatabase` in this repo; some use `deleteAllData`).

## 6. Step Definitions

### 6.1 Organization

- One `*Steps` class per domain for **action/precondition** steps (`UserSteps`, `TopicSteps`, `AnswerSteps`) — these hold the `@Dado` and `@Quando` definitions and autowire the use cases, concrete repos, factories, and the `TestContext`.
- **One** `AssertionSteps` class centralizing every `@Então`/`@E` step. Assertions are shared across domains (user, topic, answer, generic failure), so they must not be duplicated inside each domain steps class.
- Step methods are named in Portuguese, describing the action (`existeUsuarioAtivo`, `cadastrarUsuario`, `runCreate`). Private helpers are prefixed `run`.

### 6.2 The Exception-Capture Idiom (mandatory)

An action step must **never let a use-case exception fail the scenario mid-flow**. Instead, wrap the use-case call in `try/catch`, store the result (or `null`) and the exception in `TestContext`, and let the `@Então` step assert on it. This keeps `Quando` steps reusable across success and failure scenarios.

```java
@Quando("eu criar uma resposta com conteúdo {string} para o tópico do usuário cadastrado")
public void criarResposta(String content) {
  runCreate(content, context.topic.getId().toString(), context.author.getId().toString());
}

private void runCreate(String content, String topicId, String authorId) {
  try {
    context.createdAnswer = createAnswerUseCase.execute(new CreateAnswerRequest(content, topicId, authorId));
    context.exception = null;
  } catch (RuntimeException e) {
    context.createdAnswer = null;
    context.exception = e;
  }
}
```

- **Success path:** assign the result and set `context.exception = null`.
- **Failure path:** null out the expected result and store the `RuntimeException` in `context.exception`.
- Private `runX(...)` helpers centralize shared request-building and catch logic so public step methods stay one-liners.
- `String` Gherkin params map directly to method arguments (`{string}` → `String`, `{int}` → `int`).

### 6.3 `@Dado` Preconditions Use Factories

Preconditions persist data through `*Factory.persisteX(...)` (Section 7). When a step needs an entity in a non-default state, build an in-memory object with `*Factory.makeX()`, mutate it, and save via the concrete repository.

```java
@Dado("que existe um usuário inativo cadastrado")
public void existeUsuarioInativo() {
  var user = UserFactory.makeUser();
  user.deactivate();
  context.author = userRepository.save(user);
}
```

### 6.4 `AssertionSteps` and the Exception Map

All `@Então`/`@E` assertions live here and read from `TestContext`. The generic failure steps use a `switch` mapping the Gherkin exception name to the real class.

```java
@Então("a operação deve falhar com a exceção {string}")
public void operacaoFalhaComExcecao(String exceptionName) {
  assertThat(context.exception).isNotNull();
  assertThat(context.exception).isInstanceOf(exceptionClass(exceptionName));
}

@E("a mensagem da exceção deve conter {string}")
public void mensagemDaExcecaoContem(String text) {
  assertThat(context.exception.getMessage()).contains(text);
}

private Class<? extends RuntimeException> exceptionClass(String name) {
  return switch (name) {
    case "UserNotFoundException" -> UserNotFoundException.class;
    case "ResourceNotFoundException" -> ResourceNotFoundException.class;
    case "InactiveResourceException" -> InactiveResourceException.class;
    case "NotAllowedResourceException" -> NotAllowedResourceException.class;
    case "UserAlreadyExistsException" -> UserAlreadyExistsException.class;
    default -> throw new IllegalArgumentException("Exceção desconhecida: " + name);
  };
}
```

- **Add a new case to the switch whenever a new application exception needs a generic failure step.** If the exception name doesn't exist, the switch throws `IllegalArgumentException` — by design, so mismatched feature text fails loudly.
- Assert failure **instance** with `isInstanceOf(...)` and, when applicable, the **message** with `.contains(...)`.
- Assert the **negative side effect** on failure paths by querying the concrete repository, e.g.:

```java
@E("nenhuma resposta deve ser criada")
public void nenhumaRespostaCriada() {
  assertThat(answerRepository.findManyByTopicId(context.topic.getId(), 0, 10)).isEmpty();
}
```

## 7. Factories — Generating Fake Data

Reuse `@Component` `*Factory` classes to build and persist domain entities with fake data. **Convention in this repo:** factories use `@Autowired` field injection of the **concrete `*RepositoryImpl`** (the same concrete type used in `Hooks` and steps) and `com.github.javafaker.Faker`. If a target repo's factories use interface injection instead, mirror it.

```java
package br.alura.ForumHub.factory;

import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.github.javafaker.Faker;

import br.alura.ForumHub.domain.entity.User;
import br.alura.ForumHub.infra.persistence.repository.UserRepositoryImpl;

@Component
public class UserFactory {

  @Autowired
  private UserRepositoryImpl userRepository;

  @Autowired
  private PasswordEncoder passwordEncoder;

  private static Faker faker = new Faker();

  public static User makeUser(String name, String username, String email, String password) {
    User user = new User(name, username, email, password);
    return user;
  }

  public static User makeUser() {
    var name = faker.name().fullName();
    var username = faker.lorem().characters(15);
    var email = faker.internet().emailAddress();
    var password = faker.internet().password();

    User user = new User(name, username, email, password);
    return user;
  }

  public User persisteUser() {
    User user = makeUser();
    user.setPassword(passwordEncoder.encode(user.getPassword()));
    return userRepository.save(user);
  }
}
```

Rules:
- `@Component`, dependencies as `@Autowired` fields of the **concrete `*Impl`** repository type (this repo's convention).
- `private static Faker faker = new Faker();` from `com.github.javafaker.Faker` — a plain static field, not injected.
- **Static `makeX()`** → builds an in-memory domain object, does **not** persist. Provide a no-arg overload (random fake data) and an explicit-args overload (reproducible data).
- **Instance `persisteX()`** → builds **and saves** via the injected repository. Method name follows the repo (`persisteUser`, `persisteTopic`, `persisteAnswer`).
- If the entity has a password, `persisteX()` encodes it first via the injected `PasswordEncoder`.
- Faker recipes: `faker.name().fullName()`, `faker.lorem().characters(n)`, `faker.lorem().sentence()`, `faker.lorem().paragraph()`, `faker.internet().emailAddress()`, `faker.internet().password()`, `faker.selection().oneOf(Enum.class)`.
- When a use-case call needs IDs, wire them from `context` (e.g., `context.topic.getId()`), not fresh fake IDs.

## 8. Flow of a New BDD Feature

1. Add the `.feature` file under `src/test/resources/features/` with `# language: pt` and one scenario per behavior (happy path + each failure branch), reusing existing step sentences where possible.
2. Add any new `@Dado`/`@Quando` step methods to the matching domain `*Steps` class, using the exception-capture idiom and private `runX` helpers.
3. Add any new `@Então`/`@E` assertions to `AssertionSteps`; add new exception names to `exceptionClass(...)`.
4. Add new `TestContext` fields for any new state the scenarios need to carry.
5. Add factory methods (`makeX`/`persisteX`) if a new data shape is needed.
6. Run the BDD suite (Section 10) until green; Cucumber reports undefined steps in the `pretty` plugin output, so iterate feature ↔ steps until all are defined.

## 9. Database Strategy

### 9.1 Testcontainers (preferred)

BDD suites prefer a real, disposable database container. The Cucumber-compatible way is to declare a **static container + `@DynamicPropertySource`** inside `SpringCucumberConfig` — this avoids JUnit Jupiter's `@Testcontainers` extension, which Cucumber does not run.

```java
package br.alura.ForumHub.bdd;

import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;

import io.cucumber.spring.CucumberContextConfiguration;

@CucumberContextConfiguration
@SpringBootTest
public class SpringCucumberConfig {

  static final PostgreSQLContainer<?> POSTGRES =
      new PostgreSQLContainer<>("postgres:16-alpine");

  static {
    POSTGRES.start();
  }

  @DynamicPropertySource
  static void configureDatabase(DynamicPropertyRegistry registry) {
    registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
    registry.add("spring.datasource.username", POSTGRES::getUsername);
    registry.add("spring.datasource.password", POSTGRES::getPassword);
  }
}
```

Required dependencies:

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-testcontainers</artifactId>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>org.testcontainers</groupId>
  <artifactId>postgresql</artifactId>
  <scope>test</scope>
</dependency>
<dependency>
  <groupId>org.testcontainers</groupId>
  <artifactId>junit-jupiter</artifactId>
  <scope>test</scope>
</dependency>
```

Testcontainers requires a running Docker daemon. If the target repository already configures a test datasource in `src/test/resources/application.properties` (e.g., H2), **mirror the repo** instead of forcing a container — repo conventions win.

### 9.2 Repo Fallback (e.g., in-memory H2)

This repository currently uses an in-memory H2 test datasource. It lives in `src/test/resources/application.properties` and needs no extra boilerplate:

```properties
spring.datasource.url=jdbc:h2:mem:testdb
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=
spring.jpa.hibernate.ddl-auto=create-drop
```

When the repo adopts Testcontainers, prefer Section 9.1 and delete the H2 override — until then, keep the existing test datasource untouched.

## 10. Best Practices and Principles (F.I.R.S.T.)

1. **Fast:** The Spring context is loaded once per suite via `SpringCucumberConfig` and reused across all scenarios; never reload it per scenario.
2. **Independent:** The `@Before` hook wipes the DB in FK order and `@ScenarioScope` isolates `TestContext`, so scenarios never depend on each other or on execution order.
3. **Repeatable:** Always run against a disposable test database (Testcontainers or the repo's configured test datasource), never a shared external database.
4. **Self-Validating:** Every scenario ends in `@Então`/`@E` steps backed by AssertJ `assertThat` — no reliance on console output.
5. **Thorough:** Cover the happy path **and** every failure branch of the use case — not-found, inactive author/topic, not-owner, duplicate unique field — each with its own scenario, plus a negative side-effect assertion.

## 11. Checklist before finishing a BDD feature

- [ ] Feature file under `src/test/resources/features/`, first line `# language: pt`, snake_case filename matching the `Funcionalidade:` label.
- [ ] One `Cenário:` per behavior: happy path first, then each failure branch.
- [ ] Reuses existing step sentences across files (`Dado que existe um usuário ativo cadastrado`, `Então a operação deve falhar com a exceção "..."`, ...).
- [ ] Every `@Quando` action uses the exception-capture idiom (try/catch → `TestContext.exception`), never lets an exception fail the scenario mid-flow.
- [ ] Step methods in Portuguese, one-liner public methods delegating to private `runX(...)` helpers where shared logic exists.
- [ ] All `@Então`/`@E` assertions live in `AssertionSteps`, not scattered across domain steps classes.
- [ ] New exception names added to the `exceptionClass(...)` switch in `AssertionSteps`.
- [ ] New shared state added as `public` fields in `TestContext` (`@Component @ScenarioScope`).
- [ ] Preconditions built via `*Factory.persisteX(...)` (saved) or `*Factory.makeX()` + manual mutation + repository save.
- [ ] Failure scenarios assert both the exception (instance + message `.contains(...)`) **and** a negative side effect (e.g., `findManyByTopicId(...)).isEmpty()`).
- [ ] Database strategy matches the repo (Testcontainers preferred; otherwise the repo's existing test datasource).
- [ ] No Mockito, no context slices, no `System.out`, no stray comments.
- [ ] Run the suite with the repo's test command (e.g., `./mvnw test`) and confirm no undefined steps remain in the `pretty` output.

## 12. Running the BDD Suite

Run the full test suite (unit, integration, and BDD) with the repo's build tool:

```bash
./mvnw test
# or: mvn test
```

The runner is `CucumberRunnerTest` (`@Suite`, `@IncludeEngines("cucumber")`), so it runs with the normal test phase. The `pretty` plugin plus the HTML report (`target/cucumber-reports.html`) show which scenarios passed and whether any step definitions are missing. Feature files under `src/test/resources/features` not yet backed by steps fail with "undefined steps" — implement them before committing.
