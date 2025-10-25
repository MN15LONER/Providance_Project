# Contributing to Muni-Report Pro

Thank you for your interest in contributing to Muni-Report Pro! This document provides guidelines and instructions for contributing to the project.

## 📋 Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Coding Standards](#coding-standards)
5. [Commit Guidelines](#commit-guidelines)
6. [Pull Request Process](#pull-request-process)
7. [Testing Guidelines](#testing-guidelines)
8. [Documentation](#documentation)

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of:
- Age, body size, disability, ethnicity, gender identity and expression
- Level of experience, nationality, personal appearance, race, religion
- Sexual identity and orientation

### Our Standards

**Positive behavior includes:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what's best for the community
- Showing empathy towards other community members

**Unacceptable behavior includes:**
- Trolling, insulting/derogatory comments, and personal attacks
- Public or private harassment
- Publishing others' private information without permission
- Other conduct which could reasonably be considered inappropriate

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:
- [ ] Flutter SDK (3.0.0+) installed
- [ ] Git configured
- [ ] IDE setup (VS Code or Android Studio)
- [ ] Firebase account (for testing)
- [ ] Read the [README.md](README.md)
- [ ] Read the [SETUP_GUIDE.md](SETUP_GUIDE.md)

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Click "Fork" on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/muni-report-pro.git
   cd muni-report-pro
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/muni-report-pro.git
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Configure Firebase**
   ```bash
   flutterfire configure
   ```

6. **Run the app**
   ```bash
   flutter run
   ```

---

## Development Workflow

### Branch Strategy

We use **Git Flow** branching model:

```
main (production)
  ↓
develop (integration)
  ↓
feature/* (new features)
bugfix/* (bug fixes)
hotfix/* (urgent fixes)
```

### Creating a Feature Branch

```bash
# Update develop branch
git checkout develop
git pull upstream develop

# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git add .
git commit -m "feat: add your feature"

# Push to your fork
git push origin feature/your-feature-name
```

### Branch Naming Convention

- `feature/` - New features (e.g., `feature/issue-reporting`)
- `bugfix/` - Bug fixes (e.g., `bugfix/login-error`)
- `hotfix/` - Urgent production fixes (e.g., `hotfix/security-patch`)
- `docs/` - Documentation updates (e.g., `docs/setup-guide`)
- `refactor/` - Code refactoring (e.g., `refactor/auth-repository`)
- `test/` - Test additions (e.g., `test/auth-tests`)

---

## Coding Standards

### Dart Style Guide

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// ✅ Good
class UserRepository {
  Future<User> getUserById(String id) async {
    // Implementation
  }
}

// ❌ Bad
class user_repository {
  Future<User> get_user_by_id(String id) async {
    // Implementation
  }
}
```

### Clean Architecture Principles

**Dependency Rule**: Dependencies point inward
```
Presentation → Domain ← Data
```

**Example Structure**:
```dart
// Domain (entities and use cases)
class User {
  final String id;
  final String name;
  // Pure business logic
}

// Data (models and repositories)
class UserModel extends User {
  // Serialization logic
}

// Presentation (UI and state)
class UserProvider extends StateNotifier<UserState> {
  // UI state management
}
```

### Code Quality Rules

1. **Use meaningful names**
   ```dart
   // ✅ Good
   final userRepository = ref.read(userRepositoryProvider);
   
   // ❌ Bad
   final ur = ref.read(urp);
   ```

2. **Keep functions small**
   ```dart
   // ✅ Good - Single responsibility
   Future<void> signIn(String email, String password) async {
     await _validateCredentials(email, password);
     await _authenticateUser(email, password);
     await _updateUserSession();
   }
   
   // ❌ Bad - Too many responsibilities
   Future<void> signIn(String email, String password) async {
     // 100 lines of code...
   }
   ```

3. **Use const constructors**
   ```dart
   // ✅ Good
   const Text('Hello');
   
   // ❌ Bad
   Text('Hello');
   ```

4. **Prefer final over var**
   ```dart
   // ✅ Good
   final user = await getUser();
   
   // ❌ Bad
   var user = await getUser();
   ```

5. **Handle errors properly**
   ```dart
   // ✅ Good
   try {
     await repository.signIn(email, password);
   } on AuthFailure catch (e) {
     showError(e.message);
   } catch (e) {
     showError('An unexpected error occurred');
   }
   
   // ❌ Bad
   await repository.signIn(email, password);
   ```

### File Organization

```dart
// 1. Imports (grouped and sorted)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';

// 2. Constants
const int maxRetries = 3;

// 3. Main class
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Implementation
  }
}

// 4. Private helper classes/functions
class _LoginForm extends StatelessWidget {
  // Implementation
}
```

---

## Commit Guidelines

### Conventional Commits

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Commit Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes
- `build`: Build system changes

### Examples

```bash
# Feature
git commit -m "feat(auth): add Google Sign-In support"

# Bug fix
git commit -m "fix(issues): resolve photo upload error"

# Documentation
git commit -m "docs(readme): update setup instructions"

# Refactoring
git commit -m "refactor(auth): simplify repository logic"

# Breaking change
git commit -m "feat(api)!: change user endpoint structure

BREAKING CHANGE: User API now returns different structure"
```

### Commit Message Rules

1. Use imperative mood ("add" not "added")
2. Don't capitalize first letter
3. No period at the end
4. Keep subject line under 50 characters
5. Separate subject from body with blank line
6. Wrap body at 72 characters
7. Explain what and why, not how

---

## Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] No linting errors
- [ ] Commits follow convention

### Creating a Pull Request

1. **Update your branch**
   ```bash
   git checkout develop
   git pull upstream develop
   git checkout feature/your-feature
   git rebase develop
   ```

2. **Push to your fork**
   ```bash
   git push origin feature/your-feature
   ```

3. **Create PR on GitHub**
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Base: `develop`, Compare: `feature/your-feature`
   - Fill in the PR template

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests pass
- [ ] No linting errors
```

### Review Process

1. **Automated checks** run (tests, linting)
2. **Code review** by maintainers
3. **Address feedback** if needed
4. **Approval** by at least one maintainer
5. **Merge** to develop branch

---

## Testing Guidelines

### Test Structure

```dart
// test/features/auth/data/repositories/auth_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AuthRepository', () {
    late AuthRepository repository;
    late MockFirebaseAuth mockAuth;
    
    setUp(() {
      mockAuth = MockFirebaseAuth();
      repository = AuthRepository(firebaseAuth: mockAuth);
    });
    
    group('signIn', () {
      test('should return User on successful sign in', () async {
        // Arrange
        when(mockAuth.signInWithEmailAndPassword(
          email: any,
          password: any,
        )).thenAnswer((_) async => mockUserCredential);
        
        // Act
        final result = await repository.signInWithEmailAndPassword(
          email: 'test@test.com',
          password: 'password',
        );
        
        // Assert
        expect(result, isA<User>());
      });
      
      test('should throw AuthFailure on invalid credentials', () async {
        // Arrange
        when(mockAuth.signInWithEmailAndPassword(
          email: any,
          password: any,
        )).thenThrow(FirebaseAuthException(code: 'wrong-password'));
        
        // Act & Assert
        expect(
          () => repository.signInWithEmailAndPassword(
            email: 'test@test.com',
            password: 'wrong',
          ),
          throwsA(isA<AuthFailure>()),
        );
      });
    });
  });
}
```

### Test Coverage Goals

- **Unit tests**: 80%+ coverage
- **Widget tests**: Critical UI components
- **Integration tests**: Main user flows

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/auth/auth_test.dart

# Run tests in watch mode
flutter test --watch
```

---

## Documentation

### Code Documentation

```dart
/// Repository for authentication operations.
///
/// Handles user sign in, sign up, and profile management
/// using Firebase Authentication and Firestore.
class AuthRepository {
  /// Signs in user with email and password.
  ///
  /// Throws [AuthFailure] if credentials are invalid.
  /// Throws [NetworkFailure] if network is unavailable.
  ///
  /// Example:
  /// ```dart
  /// final user = await repository.signInWithEmailAndPassword(
  ///   email: 'user@example.com',
  ///   password: 'password123',
  /// );
  /// ```
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Implementation
  }
}
```

### README Updates

When adding features, update:
- Feature list
- Setup instructions (if needed)
- Usage examples
- Screenshots

### Changelog Updates

Add entries to [CHANGELOG.md](CHANGELOG.md):
```markdown
### [1.1.0] - 2025-11-01

#### Added
- Issue reporting feature with photo upload
- GPS location tagging
- Offline queue for submissions
```

---

## Questions?

- 📧 Email: dev@munireportpro.co.za
- 💬 GitHub Discussions
- 🐛 GitHub Issues

---

## Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project website (when available)

---

**Thank you for contributing to Muni-Report Pro! Together, we're building better communities. 🚀**
