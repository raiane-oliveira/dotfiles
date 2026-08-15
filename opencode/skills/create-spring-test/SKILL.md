---
name: create-spring-test
description: "Generate Spring Boot tests (unit and integration) that follow the team's definitive conventions. Use when the user asks to create a test, write tests, 'create a test', 'add a test for X', 'escreva um teste', or wants to cover a Java class (use case, service, controller, domain)."
---

# Spring Boot Test Conventions

**Objective:** Standardize the creation and maintenance of automated tests in Spring Boot applications — unit and integration — ensuring consistent style, readability, and maintainability across every test file.
 
**Default style:** Unless the user explicitly asks for isolated Mockito unit tests, write unit tests for use cases/services/domain classes against **real repository behavior via the In-Memory Repository pattern** (Section 5.1) — no Spring context, everything instantiated by hand in `@BeforeEach`, following Section 4.1. Do not default to `@Mock`/`@InjectMocks`, and do not default to `@SpringBootTest` for these tests — a full Spring context is reserved for controller integration tests (Section 4.2).
 
**Fallback clause:** The rules below are the team standard. If the target repository's existing test suite visibly deviates from them (naming, package layout, `*Impl` vs interface, FK cleanup order), **mirror the repo** — read 2–3 neighboring test files first and copy their style. Repo conventions win over this guide.
 
**Standard Stack:**
- JUnit 5 (Jupiter) — `assertThrows` for exception assertions
- AssertJ — `assertThat` for value/state assertions
- Real repository implementations by default — **In-Memory Repository** test doubles (Section 5.1) for use case/domain unit tests, no Spring context; concrete `*Impl` classes wired via `@SpringBootTest` only for controller integration tests (Section 4.2). **No Mockito by default**.
- `*Factory` test classes (`@Component`) for building and persisting data

---
 
## 1. Naming Conventions
 
### 1.1 Test Class
- Use case / service / domain tests: `<ClassUnderTest>Test` (e.g., `CreateAnswerUseCaseTest`).
- Web tests: `<ControllerName>ControllerIT` (e.g., `AnswerControllerIT`).

### 1.2 Test Methods
Prefix methods with `test` followed by a short description of the scenario. Rely on `@DisplayName` for the human-readable explanation — the method name itself can be terser.
 
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
 
Controllers additionally prefix the display name with the endpoint verb: `@DisplayName("[POST /users] Should create a user successfully")`, `"[GET /topics] Should list topics"`.
 
### 1.3 System Under Test (SUT)
When the class under test is instantiated directly (typically an isolated unit test without a Spring context), name the instance **`sut`** (System Under Test). This makes it immediately clear which object is the focus of the test, especially when dealing with multiple injected dependencies or complex setups. In `@SpringBootTest` integration tests the SUT is an `@Autowired` bean and is referenced by its real bean name (e.g., `createAnswerUseCase`).
 
---
 
## 2. Test Structure
 
Tests don't need explicit `// Arrange / Act / Assert` comments — they should visually flow in that order: build/persist data first, execute the action, then assert. No stray comments, no `System.out`. Prefer `var` (including for the SUT) to keep tests concise.
 
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
 
- Static imports first (assertj → hamcrest → mockmvc), then `java.*`, then `org.junit.*`, then `org.springframework.*`, then target-aware packages; then the file's own package imports — imitate the target file's import order.
- Method visibility is `void`, named `testSomething`.
- No stray comments, no `System.out`, never `new` a repo/use case — `@Autowired` fields (test classes) or constructor-injected fields (Factories, see Section 5) only.

---
 
## 4. Types of Tests in Spring Boot
 
### 4.1. Use Case / Service Unit Tests (Default)
 
**No Spring context.** Instantiate the use case under test directly as `sut`, backed by **In-Memory Repository** test doubles (Section 5.1) and the relevant `*Factory` classes — all built by hand inside a plain `@BeforeEach`, no `@SpringBootTest`, no `@Autowired`. **Do not mock internal dependencies** — the use case still runs against real repository *behavior* (real `save`/`find`/filtering logic), just backed by an in-memory store instead of a database, so tests stay fast and isolated without turning into interaction-based mocks.
 
```java
class CreateAnswerUseCaseTest {
 
  private InMemoryUserRepository userRepository;
  private InMemoryTopicRepository topicRepository;
  private InMemoryAnswerRepository answerRepository;
 
  private UserFactory userFactory;
  private TopicFactory topicFactory;
 
  private CreateAnswerUseCase sut;
 
  @BeforeEach
  void setUp() {
    userRepository = new InMemoryUserRepository();
    topicRepository = new InMemoryTopicRepository();
    answerRepository = new InMemoryAnswerRepository();
 
    userFactory = new UserFactory(userRepository, new BCryptPasswordEncoder());
    topicFactory = new TopicFactory(topicRepository);
 
    sut = new CreateAnswerUseCase(answerRepository, topicRepository, userRepository);
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
 
    var answerCreated = sut.execute(answerData);
 
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
 
    assertThrows(UserNotFoundException.class, () -> sut.execute(answerDataWithoutUser));
    assertThrows(ResourceNotFoundException.class, () -> sut.execute(answerDataWithoutTopic));
 
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
 
    InactiveResourceException exception = assertThrows(InactiveResourceException.class, () -> sut.execute(answerData));
    assertThat(exception.getMessage()).contains(user.getUsername().getValue());
  }
}
```
 
**Key points:**
- A **fresh `InMemory*Repository`** is created per test inside `@BeforeEach` — that alone gives test isolation, so there's no `deleteAll()`/FK-order cleanup to manage here (that concern only applies to the real-database controller tests in Section 4.2).
- Wire the SUT and every `*Factory` **by hand** in `@BeforeEach`, passing the `InMemory*Repository` instances straight into their constructors — the exact same constructor Spring would otherwise call, just invoked directly (`new UserFactory(userRepository, passwordEncoder)`, `new CreateAnswerUseCase(answerRepository, topicRepository, userRepository)`). This works because both the use case and the Factories already depend on the repository **interface**, never the `Impl` (Section 5) — an `InMemory*Repository` satisfies that interface just as well as the real one.
- `*Factory.makeDbX(...)` (instance methods) still means "build **and persist**" — persistence now targets the in-memory store instead of a database, but the Factory contract from Section 5 is otherwise unchanged.
- `*Factory.makeX(...)` (static methods) is unchanged: build an in-memory **domain object** to mutate before persisting yourself (e.g., `UserFactory.makeUser()` then `userRepository.save(...)`).
- Assert exceptions with JUnit's `assertThrows(ExceptionClass.class, () -> ...)`, capturing the result when you need to inspect the message: `var exception = assertThrows(...); assertThat(exception.getMessage()).contains(...)`.
- Assert values/state with AssertJ's `assertThat(...)`.
- **Always assert the negative side effect too** (e.g., that nothing was persisted) when testing a failure path — checked against the in-memory store's own state, not just that the exception was thrown.

### 4.2. Web Layer (Controllers) — `*ControllerIT`
 
Controller tests are **integration tests** (hence the `*ControllerIT` suffix), not unit tests — this is the one place a full Spring context is still loaded by default. Section 4.1's in-memory/no-context rule doesn't apply here: MockMvc, real security, and the HTTP layer need the real graph wired up.
 
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
 
**This same class serves two contexts unchanged:** in controller tests (Section 4.2) Spring injects the concrete `*Impl` bean into that constructor; in use case/domain unit tests (Section 4.1) the test constructs the Factory itself and passes an `InMemory*Repository` (Section 5.1) into the exact same constructor by hand. The Factory code never needs to know or care which one it got.
 
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
- `@Component`, dependencies declared as `private final` fields of the **interface** type (`UserRepository`, not `UserRepositoryImpl`), wired through a **single constructor** — no `@Autowired` needed on it.
- Import only the repository's contract package in the Factory (e.g. `...repositories.UserRepository`). Never import or reference the `*Impl` class from a Factory file.
- `private static Faker faker = new Faker();` remains a plain static field — it isn't part of constructor injection.
- **Static `makeX()`** → in-memory object, does **not** persist (no-arg + explicit-args overloads).
- **Instance `makeDbX()`** → builds AND saves via the injected interface's `.save(...)`.
- If the entity has a password, `makeDbX()` encodes it first (constructor-inject `PasswordEncoder` alongside the repository).
- Keep the repo's spelling — often `makeDbX`.
- Use Faker for realistic data: `faker.name().fullName()`, `faker.lorem().characters(n)`, `faker.internet().emailAddress()`, `faker.internet().password()`, `faker.lorem().paragraph()`, `faker.lorem().sentence()` and `faker.selection().oneOf(Day.class)` for application enums.
- If a new required field is added to a domain constructor, only the Factory needs updating, not every test file.

### 5.1 In-Memory Repositories (Test Doubles)
 
For Section 4.1's unit tests, implement each repository interface with a plain in-memory test double instead of mocking it. This keeps use case/domain tests running against **real repository behavior** (real `save`, `findById`, filtering, uniqueness checks, etc.) without a database or Spring context — closer to the real thing than a mock, faster than an integration test.
 
**Rules:**
- One `InMemory<Entity>Repository` class per repository interface, implementing that interface directly — **no Spring stereotype annotation** (`@Component`/`@Repository`), since it's always constructed manually with `new`, never scanned or injected by Spring.
- Location: `src/test/java/.../repositories/inmemory/` (or wherever the target repo already keeps test doubles — Fallback clause applies).
- Backing store: a plain `Map<UUID, Entity>` (or whatever the entity's real ID type is) as a `private final` field — a `HashMap` is enough; no thread-safety needed for single-threaded test execution.
- Implement **every** method the interface declares, including custom finders (`findManyByTopicId`, etc.) — replicate the real query logic with plain Java (`Map`/`Stream`) rather than leaving it unimplemented or throwing `UnsupportedOperationException`.
- `save(entity)`: generate an ID with `UUID.randomUUID()` if the entity doesn't already have one, put it in the map, and return the saved entity — mirroring what the real `*Impl` does.
- `deleteAll()`: still implement it (`map.clear()`) even though Section 4.1 no longer needs to call it in `@BeforeEach` (a fresh instance already gives isolation) — some SUTs call `deleteAll()` themselves as part of their own logic.

```java
// InMemoryUserRepository.java (test source, e.g. src/test/java/.../repositories/inmemory/InMemoryUserRepository.java)
public class InMemoryUserRepository implements UserRepository {
 
  private final Map<UUID, User> users = new HashMap<>();
 
  @Override
  public User save(User user) {
    if (user.getId() == null) {
      user.setId(UUID.randomUUID());
    }
    users.put(user.getId(), user);
    return user;
  }
 
  @Override
  public Optional<User> findById(UUID id) {
    return Optional.ofNullable(users.get(id));
  }
 
  @Override
  public List<User> findAll() {
    return new ArrayList<>(users.values());
  }
 
  @Override
  public void deleteAll() {
    users.clear();
  }
}
```
 
- **Never reuse the production `*Impl`** (e.g. `UserRepositoryImpl`) as the test double — that class talks to a real database/JPA and defeats the purpose. The in-memory double is a separate, test-only implementation of the same interface.
- If the interface exposes a method whose real implementation relies on database-specific behavior (pagination, sorting, a `LIKE` query), replicate the *observable contract* with `Stream`/`Comparator`, not the SQL — good enough for a use case test to exercise its branching logic.
- Hand the SUT and Factories the in-memory instance through their **existing constructors** (see above) — nothing about the constructor signature changes between "Spring injects the `*Impl` bean" and "the test passes the `InMemory*Repository` by hand"; that's exactly why Factories and use cases depend on the interface instead of the `Impl` in the first place.

### 5.2 Resolving Bean Ambiguity (`@Qualifier`)
 
This section only applies where **Spring is doing the wiring** — controller tests (Section 4.2) or any Factory injected inside a `@SpringBootTest`. Manually-constructed unit tests (Section 4.1) never hit bean ambiguity: there's no Spring container involved, so there's nothing for Spring to disambiguate.
 
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
- The same fix applies if the ambiguity surfaces on an `@Autowired` field inside a `*IT` controller class (Section 4.2) rather than a Factory constructor — both files live under `src/test/java`, so annotating there still satisfies the "test package only" constraint. Unit tests (Section 4.1) don't have `@Autowired` fields at all, so this never comes up there.
- If resolving the ambiguity would require touching anything under `src/main/java` (a `@Configuration` class, adding `@Primary`, renaming/removing a bean), **stop and flag it to the user** instead of making that change — it's out of scope for a test-file fix.
---
 
## 6. Best Practices and Principles (F.I.R.S.T.)
 
1. **Fast:** Use case/domain unit tests (Section 4.1) load no Spring context at all — the SUT and `InMemory*Repository` instances are built directly, so there's no container startup cost to manage. Reserve context reuse across a test class (default `@SpringBootTest` behavior) for the controller integration tests in Section 4.2.
2. **Independent:** For unit tests (4.1), a **brand-new `InMemory*Repository` instance per test**, created in `@BeforeEach`, is isolation by construction — no cleanup call needed. For controller integration tests (4.2) that hit a real database, `@BeforeEach` must still fully reset state (`deleteAll()` in FK order) so tests never depend on each other or on execution order.
3. **Repeatable:** Unit tests (4.1) are repeatable everywhere by construction — there's no database involved. Controller integration tests (4.2) still need a test profile / disposable test database (e.g., Testcontainers or an embedded DB), never a shared external database.
4. **Self-Validating:** Every test must end in clear `assertThat`/`assertThrows` calls — no reliance on console output.
5. **Thorough:** Cover the happy path and, most importantly, every failure branch (not-found, inactive/invalid state, invalid input) — mirroring each `throw` in the class under test with its own test method.
---
 
## 7. Checklist before finishing a test file
 
- [ ] No Spring context for use case/domain unit tests (Section 4.1) — SUT, `*Factory`, and `InMemory*Repository` instances all built by hand in `@BeforeEach`, no `@SpringBootTest`, no `@Autowired`. `@SpringBootTest` reserved for controller integration tests (Section 4.2); `@ExtendWith(MockitoExtension.class)` only for the explicit unit-test exception (Section 4.4).
- [ ] `*Test` (unit, 4.1): every field constructed manually — `new InMemory*Repository()`, `new *Factory(...)`, `new <UseCase>(...)`. `*IT` (controller, 4.2): `@Autowired` fields only — never `new` a repo/use case; may reference concrete `*Impl` repositories directly.
- [ ] `*Factory` classes: constructor-injected repository **interfaces** only — never `@Autowired`, never import the `*Impl` class (Section 5). The same constructor is called by Spring in 4.2 and by hand in 4.1.
- [ ] Unit test doubles are `InMemory*Repository` classes implementing the real interface (Section 5.1) — never the production `*Impl`, never a Mockito mock.
- [ ] Any `NoUniqueBeanDefinitionException`/bean-ambiguity error (only possible where Spring wires things — Section 4.2) is resolved with `@Qualifier` inside `src/test/java` only — no production/config file changes (Section 5.2).
- [ ] Method visibility `void`, named `testSomething`. [ ] `@DisplayName` describing behavior; prefix with `[METHOD /path]` for controllers.
- [ ] Unit tests (4.1): `@BeforeEach` builds fresh `InMemory*Repository` + `*Factory` + SUT instances, no `deleteAll()` needed. Controller ITs (4.2): `@BeforeEach` cleans the real DB in FK order (child → parent); adapt its name to the target repo.
- [ ] Data built via `*Factory.makeDbX(...)` (saved) or `*Factory.makeX(...)` + manual `repository.save()` (when mutating a domain object).
- [ ] Error paths assert the thrown exception AND a negative side effect + message `.contains(...)`.
- [ ] No Mockito in default unit/integration tests, no stray comments, SUT named `sut` in unit tests, no `System.out`.
- [ ] Run the repo's test command (e.g., `./mvnw test`, `mvn test`, or Gradle) to verify.
---
 
## 8. Extra Tips
 
- **Unit tests (4.1) build everything by hand — no `@Autowired` anywhere.** `InMemory*Repository` instances, `*Factory` instances, and the SUT are all constructed with `new` inside `@BeforeEach`.
- **Avoid `@Autowired` in constructors inside `*IT` classes (4.2):** JUnit requires a no-args constructor by default; inject into `@Autowired` fields there instead. Factories are the exception — they're plain Spring `@Component` beans when wired by Spring, so constructor injection works normally and is the required pattern (Section 5).
- **In-memory repositories aren't Spring beans:** don't annotate `InMemory*Repository` with `@Component`/`@Repository` and don't try to `@Autowired` it — that only invites Spring to pick it up alongside the production `*Impl` and creates ambiguity for no reason. Construct it with `new` inside `@BeforeEach`, once per test (Section 5.1).
- **Exception assertions (JUnit 5):**
```java
var exception = assertThrows(InactiveResourceException.class, () -> sut.execute(answerData));
assertThat(exception.getMessage()).contains(topic.getTitle());
```
- **Use `@DisplayName`** on every test method to improve readability in Sonar/Jenkins/GitHub Actions.
- **Unit tests (4.1) don't need to clear anything** — a fresh `InMemory*Repository` per test already starts empty. For controller ITs (4.2), clear the database in `@BeforeEach`, not `@AfterEach` — this keeps failed test data around for debugging until the next test runs.
- **Assert side effects, not just exceptions:** when testing a failure path, also confirm nothing was persisted (e.g., `assertThat(repository.findAll()).isEmpty()`, `.findManyByTopicId(...)).isEmpty()`).
- **Bean ambiguity is a test-file problem to solve with `@Qualifier`, not a production-code problem:** it can only happen where Spring wires things (Section 4.2). If a Factory's interface-based constructor can't resolve, annotate the parameter — don't reach for `@Primary`, don't edit `@Configuration`, don't touch `src/main/java` (Section 5.2).
