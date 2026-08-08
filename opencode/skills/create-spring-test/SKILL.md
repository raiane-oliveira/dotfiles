---
name: create-spring-test
description: "Generate Spring Boot tests (unit and integration) that follow the team's definitive conventions. Use when the user asks to create a test, write tests, 'create a test', 'add a test for X', 'escreva um teste', or wants to cover a Java class (use case, service, controller, domain)."
---

# Spring Boot Test Conventions

**Objective:** Standardize the creation and maintenance of automated tests in Spring Boot applications — unit and integration — ensuring consistent style, readability, and maintainability across every test file.

**Default style:** Unless the user explicitly asks for isolated Mockito unit tests, write **full Spring context integration tests** against real repository implementations, following Section 4.1. Do not default to `@Mock`/`@InjectMocks`.

**Fallback clause:** The rules below are the team standard. If the target repository's existing test suite visibly deviates from them (naming, package layout, `*Impl` vs interface, FK cleanup order), **mirror the repo** — read 2–3 neighboring test files first and copy their style. Repo conventions win over this guide.

**Standard Stack:**
- JUnit 5 (Jupiter) — `assertThrows` for exception assertions
- AssertJ — `assertThat` for value/state assertions
- Spring Boot Test (`@SpringBootTest`, real repository implementations, **no Mockito by default**)
- `*Factory` test classes (`@Component`) for building and persisting data

---

## 1. Naming Conventions

### 1.1 Test Class
- Use case / service / domain tests: `<ClassUnderTest>Test` (e.g., `CreateAnswerUseCaseTest`).
- Web tests: `<ControllerName>ControllerIT` (e.g., `AnswerControllerIT`).

### 1.2 Test Methods
Prefix methods with `test` followed by a short description of the scenario. Rely on
`@DisplayName` for the human-readable explanation — the method name itself can be terser.

**Recommended standard: `test[Scenario]`**
- ✅ `testCreateAnswer()`
- ✅ `testCreateAnswerWithNonTopicAndUser()`
- ❌ `shouldReturnAnswerWhenDataIsValid()` (not the convention — do not use)

Always pair with `@DisplayName` describing the expected behavior in plain English:

```java
@Test
@DisplayName("Should not create an answer with an inactive topic")
void testCreateAnswerWithInactiveTopic() { ... }
```

Controllers additionally prefix the display name with the endpoint verb:
`@DisplayName("[POST /users] Should create a user successfully")`, `"[GET /topics] Should list topics"`.

### 1.3 System Under Test (SUT)
When the class under test is instantiated directly (typically an isolated unit test without a
Spring context), name the instance **`sut`** (System Under Test). This makes it immediately clear
which object is the focus of the test, especially when dealing with multiple injected dependencies
or complex setups. In `@SpringBootTest` integration tests the SUT is an `@Autowired` bean and is
referenced by its real bean name (e.g., `createAnswerUseCase`).

---

## 2. Test Structure

Tests don't need explicit `// Arrange / Act / Assert` comments — they should visually flow
in that order: build/persist data first, execute the action, then assert. No stray comments,
no `System.out`. Prefer `var` (including for the SUT) to keep tests concise.

```java
@Test
@DisplayName("Should create an answer successfully")
void testCreateAnswer() {
  var user = userFactory.makeDbUser();
  var topic = topicFactory.makeDbTopic(user.getId());

  var answerData = new CreateAnswerRequest(
      "This is a test answer content",
      topic.getId().toString(),
      user.getId().toString());

  var answerCreated = createAnswerUseCase.execute(answerData);

  assertThat(answerCreated).isNotNull();
  assertThat(answerCreated.getTopicId()).isEqualTo(topic.getId());
  assertThat(answerCreated.getAuthorId()).isEqualTo(user.getId());
}
```

---

## 3. Import Order & Style Hygiene

- Static imports first (assertj → hamcrest → mockmvc), then `java.*`, then `org.junit.*`,
  then `org.springframework.*`, then target-aware packages; then the file's own package
  imports — imitate the target file's import order.
- Method visibility is `void`, named `testSomething`.
- No stray comments, no `System.out`, never `new` a repo/use case — `@Autowired` fields (test
  classes) or constructor-injected fields (Factories, see Section 5) only.

---

## 4. Types of Tests in Spring Boot

### 4.1. Use Case / Service Integration Tests (Default)

Load the full Spring context with `@SpringBootTest` and autowire the real use case, the
**concrete repository implementations** (e.g., `UserRepositoryImpl`, not the interface),
and the relevant `*Factory` classes. **Do not mock internal dependencies** — let the use
case run against the real (test) database.

```java
@SpringBootTest
public class CreateAnswerUseCaseTest {

  @Autowired
  private CreateAnswerUseCase createAnswerUseCase;

  @Autowired
  private UserRepositoryImpl userRepository;

  @Autowired
  private TopicRepositoryImpl topicRepository;

  @Autowired
  private AnswerRepositoryImpl answerRepository;

  @Autowired
  private UserFactory userFactory;

  @Autowired
  private TopicFactory topicFactory;

  @BeforeEach
  void clearDatabase() {
    answerRepository.deleteAll();
    topicRepository.deleteAll();
    userRepository.deleteAll();
  }

  @Test
  @DisplayName("Should create an answer successfully")
  void testCreateAnswer() {
    var user = userFactory.makeDbUser();
    var topic = topicFactory.makeDbTopic(user.getId());

    var answerData = new CreateAnswerRequest(
        "This is a test answer content",
        topic.getId().toString(),
        user.getId().toString());

    var answerCreated = createAnswerUseCase.execute(answerData);

    assertThat(answerCreated).isNotNull();
    assertThat(answerCreated.getId()).isNotNull();
    assertThat(answerCreated.getTopicId()).isEqualTo(topic.getId());
    assertThat(answerCreated.getAuthorId()).isEqualTo(user.getId());
  }

  @Test
  @DisplayName("Should not create an answer with non-existent topic and user")
  void testCreateAnswerWithNonTopicAndUser() {
    var user = userFactory.makeDbUser();
    var topic = topicFactory.makeDbTopic(user.getId());

    var answerDataWithoutUser = new CreateAnswerRequest(
        "This is a test answer content",
        topic.getId().toString(),
        UUID.randomUUID().toString());

    var answerDataWithoutTopic = new CreateAnswerRequest(
        "This is a test answer content",
        UUID.randomUUID().toString(),
        user.getId().toString());

    assertThrows(UserNotFoundException.class, () -> createAnswerUseCase.execute(answerDataWithoutUser));
    assertThrows(ResourceNotFoundException.class, () -> createAnswerUseCase.execute(answerDataWithoutTopic));

    assertThat(answerRepository.findManyByTopicId(topic.getId(), 0, 10)).isEmpty();
  }

  @Test
  @DisplayName("Should not create an answer with an inactive user")
  void testCreateAnswerWithInactiveUser() {
    var domainUser = UserFactory.makeUser();
    domainUser.deactivate();
    var user = userRepository.save(domainUser);
    var topic = topicFactory.makeDbTopic(user.getId());

    var answerData = new CreateAnswerRequest(
        "This is a test answer content",
        topic.getId().toString(),
        user.getId().toString());

    InactiveResourceException exception = assertThrows(InactiveResourceException.class, () -> createAnswerUseCase.execute(answerData));
    assertThat(exception.getMessage()).contains(user.getUsername().getValue());
  }
}
```

**Key points:**
- Import the **concrete impl repositories** (`UserRepositoryImpl`, `TopicRepositoryImpl`,
  `AnswerRepositoryImpl`), not the interfaces, when autowiring fields **directly inside the test class** (`*Test`/`*IT`). This is intentional and different from Factories: the test class often needs impl-specific helper methods (`deleteAll()`, custom finders) that only exist on the concrete class, so it stays autowired by concrete type here.
- **Factories are the exception** to the rule above — `*Factory` classes depend on the repository **interface/contract**, not the `Impl`, and receive it via constructor injection instead of an `@Autowired` field. Don't carry that pattern into the `*Test`/`*IT` class itself unless the repo you're working in already does so (Fallback clause).
- `@BeforeEach` always clears the database in **child-to-parent** foreign-key order (e.g., answers before topics before users) so each test starts from a clean slate. Name it `clearDatabase` (some repos use `deleteAllData`/`deleteAll`). Only delete what that test class touches.
- Use `*Factory.makeDbX(...)` (instance methods) when you need entities **saved** to the database.
- Use `*Factory.makeX(...)` (static methods) when you need an in-memory domain object to mutate before persisting yourself (e.g., `UserFactory.makeUser()` then `userRepository.save(...)`).
- Assert exceptions with JUnit's `assertThrows(ExceptionClass.class, () -> ...)`, capturing the result when you need to inspect the message: `var exception = assertThrows(...); assertThat(exception.getMessage()).contains(...)`.
- Assert values/state with AssertJ's `assertThat(...)`.
- **Always assert the negative side effect too** (e.g., that nothing was persisted) when testing
  a failure path — not just that the exception was thrown.

### 4.2. Web Layer (Controllers) — `*ControllerIT`

Use `@SpringBootTest` (not `@WebMvcTest`) so the whole graph — real security, `TokenService`, repositories, factories — is available. Combine with `@AutoConfigureMockMvc` and `@AutoConfigureJsonTesters` for MockMvc + JacksonTester.

```java
@SpringBootTest
@AutoConfigureMockMvc
@AutoConfigureJsonTesters
class AnswerControllerIT {

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private JacksonTester<CreateAnswerRequestDTO> createAnswerRequestJson;

  @Autowired
  private TokenService tokenService;

  @BeforeEach
  void clearDatabase() {
    answerRepository.deleteAll();
    topicRepository.deleteAll();
    userRepository.deleteAll();
  }

  @Test
  @DisplayName("[POST /answers] Should create an answer for a topic")
  void testCreateAnswer() throws Exception {
    var user = userFactory.makeDbUser();
    var topic = topicFactory.makeDbTopic(user.getId());

    var request = new CreateAnswerRequestDTO("This is a new answer", topic.getId().toString());
    var json = createAnswerRequestJson.write(request).getJson();

    var userDB = new UserDB(user);
    var token = tokenService.generateToken(userDB);

    mockMvc.perform(
            post("/answers")
                .contentType("application/json")
                .header("Authorization", "Bearer " + token)
                .content(json))
        .andExpect(status().isCreated())
        .andExpect(jsonPath("$.content", is(request.content())))
        .andExpect(jsonPath("$.topicId", is(request.topicId().toString())));
  }
}
```

- `@DisplayName` uses the endpoint verb: `"[POST /users] Should create a user successfully"`.
- Request DTOs: `var json = <dto>Json.write(request).getJson();` — name the JacksonTester field `<dtoField>Json` (e.g., `createAnswerRequestJson`).
- Auth: prefer a real token — `var userDB = new UserDB(user); var token = tokenService.generateToken(userDB);` then `.header("Authorization", "Bearer " + token)`. `@WithMockUser` works but the real-token pattern is the repo convention when token service is configured.
- Assert with MockMvc: `status()` matchers `isOk()`, `isCreated()`, `isNoContent()`, `isForbidden()`, `isBadRequest()`, `isConflict()`; JSON with `jsonPath("$.field", is(...))`.
- Or read the raw response: `var response = mockMvc.perform(...).andReturn().getResponse(); assertThat(response.getStatus()).isEqualTo(HttpStatus.CREATED.value());`.
- Query params / pagination: `get("/topics")`, `get("/topics?size=2")`; seed with loops: `for (int i = 0; i < 22; i++) answerFactory.makeDbAnswer(user.getId(), topic.getId());`.
- After PUT/DELETE verify repository state too, e.g. `assertThat(topicRepository.findById(topic.getId())).isEmpty();`.

### 4.3. Pure Domain / Value-Object Tests

Do not use `@SpringBootTest` — slicing for pure domain classes:

```java
@ExtendWith(MockitoExtension.class)
class SlugTest {

  @Test
  @DisplayName("Should create a slug successfully")
  void testCreateSlug() {
    var slug = Slug.createFromText("Hello World!");
    assertThat(slug).isNotNull();
    assertThat(slug.getValue()).isEqualTo("hello-world");
  }
}
```

### 4.4. Mockito Unit Tests (Exception — use sparingly)

Only reach for `@Mock`/`@InjectMocks` (no Spring context) when:
- the **user explicitly asks** for a unit test, **or**
- the logic under test has **no meaningful database interaction** to verify (e.g., a pure calculation/validator class with heavy dependency graphs you don't want to wire).

For anything touching repositories or use cases, prefer Section 4.1's integration style.

```java
@ExtendWith(MockitoExtension.class)
class CalculatorTest {

  @Mock
  private Dependencies deps;

  @InjectMocks
  private Calculator sut;

  @Test
  @DisplayName("Should sum two numbers")
  void testSum() {
    assertThat(sut.sum(2, 3)).isEqualTo(5);
  }
}
```

---

## 5. Test Data Generation (Factories)

Whenever the same entity needs to be created more than a couple of times across tests, use a `@Component` Factory rather than duplicating construction logic.

**Decoupled dependency injection:** Factories depend on the repository's **interface/contract** only (e.g., `UserRepository`), never on the concrete `*Impl` class, and never import it. Spring still resolves and injects the real bean at runtime — the Factory simply stops caring which implementation that is. Wiring goes through the **constructor** rather than an `@Autowired` field: with a single constructor, Spring performs implicit constructor injection, so no `@Autowired` annotation is needed at all.

```java
// UserFactory.java (test source, e.g. src/test/java/.../factories/UserFactory.java)
import net.datafaker.Faker;

@Component
public class UserFactory {

  private final UserRepository userRepository;
  private final PasswordEncoder passwordEncoder;

  private static final Faker faker = new Faker();

  public UserFactory(UserRepository userRepository, PasswordEncoder passwordEncoder) {
    this.userRepository = userRepositoy;
    this.passwordEncoder = passwordEncoder;
  }

  // Static: build an in-memory domain object without persisting it.
  public static User makeUser() {
    return new User(
        faker.name().fullName(),
        faker.lorem().characters(15),
        faker.internet().emailAddress(),
        faker.internet().password());
  }

  // Static: explicit-args overload for reproducible domain objects.
  public static User makeUser(String name, String username, String email, String password) {
    return new User(name, username, email, password);
  }

  // Instance: build AND persist, encoding the password first.
  public User makeDbUser() {
    var user = makeUser();
    user.setPassword(passwordEncoder.encode(user.getPassword()));
    return userRepository.save(user);
  }
}
```

**Rules:**
- `@Component`, dependencies declared as `private final` fields of the **interface** type (`UserRepository`, not `UserRepositoryImpl`), wired through a **single constructor** —
  no `@Autowired` needed on it.
- Import only the repository's contract package in the Factory (e.g. `...repositories.UserRepository`). Never import or reference the `*Impl` class from a Factory file.
- `private static Faker faker = new Faker();` remains a plain static field — it isn't part of constructor injection.
- **Static `makeX()`** → in-memory object, does **not** persist (no-arg + explicit-args overloads).
- **Instance `makeDbX()`** → builds AND saves via the injected interface's `.save(...)`.
- If the entity has a password, `makeDbX()` encodes it first (constructor-inject `PasswordEncoder` alongside the repository).
- Keep the repo's spelling — often `makeDbX`.
- Use Faker for realistic data: `faker.name().fullName()`, `faker.lorem().characters(n)`, `faker.internet().emailAddress()`, `faker.internet().password()`, `faker.lorem().paragraph()`, `faker.lorem().sentence()` and `faker.selection().oneOf(Day.class)` for application enums.
- If a new required field is added to a domain constructor, only the Factory needs updating, not every test file.

### 5.1 Resolving Bean Ambiguity (`@Qualifier`)

Depending on an interface instead of the `*Impl` class means Spring must pick a bean at injection time. If more than one class implements that interface, constructor injection fails with `NoUniqueBeanDefinitionException` (or an equivalent "no qualifying bean of type ... expected single matching bean but found N" message).

**Fix this locally with `@Qualifier`, and only inside the test package — never by touching application configuration, adding `@Primary` to a production bean, deleting a competing `Impl`, or any other change outside `src/test/java`:**

```java
@Component
public class UserFactory {

  private final UserRepository userRepository;

  public UserFactory(@Qualifier("userRepositoryImpl") UserRepository userRepository) {
    this.userRepository = userRepository;
  }
  // ...
}
```

- Determine the correct qualifier name from the bean's own declaration — an explicit name on `@Repository("userRepositoryImpl")`/`@Service("...")` on the `Impl` class, or (if unnamed) Spring's default bean name: the class name with a lowercase first letter (`UserRepositoryImpl` → `userRepositoryImpl`).
- Add `@Qualifier` only to the specific constructor parameter(s) causing the conflict — don't qualify parameters that already resolve unambiguously.
- The same fix applies if the ambiguity surfaces on an `@Autowired` field inside a `*Test`/`*IT` class (Section 4.1/4.2) rather than a Factory constructor — both files live under `src/test/java`, so annotating there still satisfies the "test package only" constraint.
- If resolving the ambiguity would require touching anything under `src/main/java` (a `@Configuration` class, adding `@Primary`, renaming/removing a bean), **stop and flag it to the user** instead of making that change — it's out of scope for a test-file fix.

---

## 6. Best Practices and Principles (F.I.R.S.T.)

1. **Fast:** Keep the Spring context reused across tests in a class (default `@SpringBootTest` behavior) rather than reloading it per test.
2. **Independent:** `@BeforeEach` must fully reset state (`deleteAll()` in FK order) so tests never depend on each other or on execution order.
3. **Repeatable:** Tests must pass in any environment without manual setup — use a test profile / disposable test database (e.g., Testcontainers or an embedded DB), never a shared external database.
4. **Self-Validating:** Every test must end in clear `assertThat`/`assertThrows` calls — no reliance on console output.
5. **Thorough:** Cover the happy path and, most importantly, every failure branch (not-found, inactive/invalid state, invalid input) — mirroring each `throw` in the class under test with its own test method.

---

## 7. Checklist before finishing a test file

- [ ] `@SpringBootTest` (plain, no slices) for integration + domain tests; `@ExtendWith(MockitoExtension.class)` only for the explicit unit-test exception (Section 4.4).
- [ ] `*Test`/`*IT` classes: `@Autowired` fields only — never `new` a repo/use case; may reference concrete `*Impl` repositories directly (Section 4.1).
- [ ] `*Factory` classes: constructor-injected repository **interfaces** only — never `@Autowired`, never import the `*Impl` class (Section 5).
- [ ] Any `NoUniqueBeanDefinitionException`/bean-ambiguity error is resolved with `@Qualifier` inside `src/test/java` only — no production/config file changes (Section 5.1).
- [ ] Method visibility `void`, named `testSomething`. [ ] `@DisplayName` describing behavior; prefix with `[METHOD /path]` for controllers.
- [ ] `@BeforeEach` cleans the DB in FK order (child → parent); adapt its name to the target repo.
- [ ] Data built via `*Factory.makeDbX(...)` (saved) or `*Factory.makeX(...)` + manual `repository.save()` (when mutating a domain object).
- [ ] Error paths assert the thrown exception AND a negative side effect + message `.contains(...)`.
- [ ] No Mockito in integration tests, no stray comments, SUT named `sut` in unit tests, no `System.out`.
- [ ] Run the repo's test command (e.g., `./mvnw test`, `mvn test`, or Gradle) to verify.

---

## 8. Extra Tips

- **Avoid `@Autowired` in constructors inside `*Test`/`*IT` classes:** JUnit requires a no-args constructor by default; inject into `@Autowired` fields there instead. Factories are the exception — they're plain Spring `@Component` beans, so constructor injection works normally and is the required pattern (Section 5).
- **Exception assertions (JUnit 5):**
```java
var exception = assertThrows(InactiveResourceException.class, () -> createAnswerUseCase.execute(answerData));
assertThat(exception.getMessage()).contains(topic.getTitle());
```
- **Use `@DisplayName`** on every test method to improve readability in Sonar/Jenkins/GitHub Actions.
- **Clear the database in `@BeforeEach`, not `@AfterEach`** — this keeps failed test data around for debugging until the next test runs.
- **Assert side effects, not just exceptions:** when testing a failure path, also confirm nothing was persisted (e.g., `assertThat(repository.findAll()).isEmpty()`, `.findManyByTopicId(...)).isEmpty()`).
- **Bean ambiguity is a test-file problem to solve with `@Qualifier`, not a production-code problem:** if a Factory's interface-based constructor can't resolve, annotate the parameter — don't reach for `@Primary`, don't edit `@Configuration`, don't touch `src/main/java` (Section 5.1).
