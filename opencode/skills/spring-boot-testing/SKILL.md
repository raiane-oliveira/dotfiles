---
name: spring-boot-testing
description: "Automated testing practices for Java Spring Boot applications using JUnit 5, Spring Boot Test, and AssertJ. Use when the user wants to create integration tests for use cases/services, asks for Spring test slices (@SpringBootTest, @WebMvcTest, @DataJpaTest), needs persisted test data via Factories, or requests testing conventions."
---

# Automated Testing with Java, Spring Boot, and JUnit 5

**Objective:** Standardize the creation and maintenance of automated tests in Spring Boot applications, ensuring code quality, readability, and maintainability.

**Standard Stack:**
- JUnit 5 (Jupiter) — use `assertThrows` for exceptions
- AssertJ — use `assertThat` for value/state assertions
- Spring Boot Test (`@SpringBootTest`, real repository implementations, no internal mocking)
- Factories (`*Factory`) for building and persisting test data

**Default style:** Unless the user explicitly asks for isolated Mockito unit tests, write **full Spring context integration tests** against real repository implementations, following the pattern in Section 3. This is the team's default for use case / service tests — do not default to `@Mock`/`@InjectMocks` with Mockito.

---

## 1. Naming Conventions

### 1.1. Test Class
Name the test class after the class under test, suffixed with `Test` (e.g., `CreateAnswerUseCaseTest`).

### 1.2. Test Methods
Prefix test methods with `test` followed by a short description of the scenario. Rely on `@DisplayName` for the human-readable explanation — the method name itself can be terser.

**Recommended standard: `test[Scenario]`**
- ✅ `testCreateAnswer()`
- ✅ `testCreateAnswerWithNonTopicAndUser()`
- ✅ `testCreateAnswerWithInactiveUser()`
- ❌ `shouldReturnAnswerWhenDataIsValid()` (not the team's convention — do not use this style)

Always pair the method with `@DisplayName("Should ...")` describing expected behavior in plain English:
```java
@Test
@DisplayName("Should not create a answer with an inactive topic")
void testCreateAnswerWithInactiveTopic() { ... }
```

### 1.3. System Under Test (SUT)
Always name the instance of the class being tested as **`sut`** (System Under Test). This makes it immediately clear which object is the focus of the test, especially when dealing with multiple injected dependencies or complex setups.

---

## 2. Test Structure

Tests don't need explicit `// Arrange / Act / Assert` comments, but should still visually flow in that order: build/persist data first, execute the action, then assert. Prefer `var` obvious type variables to keep tests concise.

```java
@Test
@DisplayName("Should create an answer successfully")
void testCreateAnswer() {
  User user = userFactory.persisteUser();
  Topic topic = topicFactory.persisteTopic(user.getId());

  var answerData = new CreateAnswerRequest(
      "This is a test answer content",
      topic.getId().toString(),
      user.getId().toString());

  Answer answerCreated = createAnswerUseCase.execute(answerData);

  assertThat(answerCreated).isNotNull();
  assertThat(answerCreated.getTopicId()).isEqualTo(topic.getId());
  assertThat(answerCreated.getAuthorId()).isEqualTo(user.getId());
}
```

---

## 3. Types of Tests in Spring Boot

### 3.1. Use Case / Service Integration Tests (Default)

Load the full Spring context with `@SpringBootTest` and autowire the real use case, real repository implementations (e.g., `UserRepositoryImpl`, not the interface mock), and the relevant `*Factory` classes. **Do not mock internal dependencies** — let the use case run against the real (test) database.

```java
@SpringBootTest
public class CreateAnswerUseCaseTest {

  @Autowired
  private CreateAnswerUseCase createAnswerUseCase;

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private TopicRepository topicRepository;

  @Autowired
  private AnswerRepositor answerRepository;

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
    User user = userFactory.persisteUser();
    Topic topic = topicFactory.persisteTopic(user.getId());

    var answerData = new CreateAnswerRequest(
        "This is a test answer content",
        topic.getId().toString(),
        user.getId().toString());

    Answer answerCreated = createAnswerUseCase.execute(answerData);

    assertThat(answerCreated).isNotNull();
    assertThat(answerCreated.getId()).isNotNull();
    assertThat(answerCreated.getTopicId()).isEqualTo(topic.getId());
    assertThat(answerCreated.getAuthorId()).isEqualTo(user.getId());
  }

  @Test
  @DisplayName("Should not create an answer with non-existent topic and user")
  void testCreateAnswerWithNonTopicAndUser() {
    User user = userFactory.persisteUser();
    Topic topic = topicFactory.persisteTopic(user.getId());

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
  @DisplayName("Should not create a answer with a inactive user")
  void testCreateAnswerWithInactiveUser() {
    User domainUser = UserFactory.makeUser();
    domainUser.deactivate();
    User user = userRepository.save(domainUser);
    Topic topic = topicFactory.persisteTopic(user.getId());

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
- `@BeforeEach` always clears the database in **child-to-parent** foreign-key order (e.g., answers before topics before users) so each test starts from a clean slate.
- Use `*Factory.persisteX(...)` (autowired instance methods) when you need entities **saved** to the database.
- Use `*Factory.makeX(...)` (static methods) when you need an in-memory domain object to mutate before persisting yourself (e.g., `UserFactory.makeUser()` then `userRepository.save(...)`).
- Assert exceptions with JUnit's `assertThrows(ExceptionClass.class, () -> ...)`, capturing the result when you need to inspect the message: `var exception = assertThrows(...)`.
- Assert values/state with AssertJ's `assertThat(...)`.
- Always assert the negative side-effect too (e.g., that nothing was persisted) when testing a failure path, not just that the exception was thrown.

### 3.2. Web Layer (Controllers)

Use `@WebMvcTest` when you specifically need to test HTTP-layer concerns (status codes, serialization, validation) in isolation from business logic:

```java
@WebMvcTest(AnswerController.class)
@AutoConfigureMockMvc
@AutoConfigureJsonTesters
@Transactional
class AnswerControllerIT {

  @Autowired
  private TokenService tokenService;

  @Autowired
  private MockMvc mockMvc;

  @Autowired
  private JacksonTester<CreateAnswerRequestDTO> createAnswerRequestJson;

  // Repositories and Factories for setup

  @Test
  @DisplayName("Should create an answer for a topic")
  @WithMockUser
  void testCreateAnswer() throws Exception {
    var user = userFactory.persisteUser();
    var topic = topicFactory.persisteTopic(user.getId());

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

### 3.3. Pure Unit Tests (Exception — use sparingly)

Only reach for isolated Mockito (`@Mock`/`@InjectMocks`, no Spring context) when the user explicitly asks for a unit test, or when the logic under test has no meaningful database interaction to verify (e.g., a pure calculation/validator class). For anything touching repositories/use cases, prefer Section 3.1's integration style instead.

---

## 4. Best Practices and Principles (F.I.R.S.T.)

1. **Fast:** Keep the Spring context reused across tests in a class (default `@SpringBootTest` behavior) rather than reloading it per test.
2. **Independent:** `@BeforeEach` must fully reset state (`deleteAll()` in FK order) so tests never depend on each other or on execution order.
3. **Repeatable:** Tests must pass in any environment without manual setup — use a test profile / disposable test database (e.g., Testcontainers or an embedded DB), never a shared external database.
4. **Self-Validating:** Every test must end in clear `assertThat`/`assertThrows` calls — no relying on console output.
5. **Thorough:** Cover the happy path and, most importantly, every error branch (not-found, inactive/invalid state, invalid input) — mirroring each `throw` in the class under test with its own test method.

---

## 5. Test Data Generation (Factories)

Whenever the same entity needs to be created more than a couple of times across tests, use a `@Component` Factory rather than duplicating construction logic.

```java
// UserFactory.java (test source, e.g. src/test/java/.../factories/UserFactory.java)
import com.github.javafaker.Faker;

@Component
public class UserFactory {

  @Autowired
  private UserRepository userRepository;

  private static final Faker faker = new Faker();

  // Static: build an in-memory domain object without persisting it.
  public static User makeUser() {
    var name = faker.name().fullName();
    var username = faker.lorem().characters(15);
    var email = faker.internet().emailAddress();
    var password = faker.internet().password();
    return new User(name, username, email, password);
  }

  // Instance: build AND persist, for tests that just need existing data.
  public User persisteUser() {
    var user = makeUser();
    return userRepository.save(user);
  }
}
```

- Use the **static `makeX()`** when the test needs to mutate the object before saving it (e.g., deactivating a user to test an inactive-resource path).
- Use the **instance `persisteX()`** when the test just needs a valid, already-persisted entity as setup/background data.
- If a new required field is added to a domain constructor, only the Factory needs updating, not every test file.

---

## 6. Extra Tips

- **Avoid `@Autowired` in constructors inside the test class:** JUnit requires a no-args constructor by default; inject into fields instead.
- **Exception assertions (JUnit 5):**
```java
var exception = assertThrows(InactiveResourceException.class, () -> createAnswerUseCase.execute(answerData));
assertThat(exception.getMessage()).contains(topic.getTitle());
```
- **Use `@DisplayName`** on every test method to improve readability of test reports in Sonar/Jenkins/GitHub Actions.
- **Clear the database in `@BeforeEach`**, not `@AfterEach` — this keeps failed test data around for debugging until the next test runs.
- **Assert side effects, not just exceptions:** when testing a failure path, also confirm nothing was persisted (e.g., `assertThat(repository.findAll()).isEmpty()`).
