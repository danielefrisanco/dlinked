# Contributing to DLinked

First off, thank you for considering contributing to DLinked! It's people like you that make open source such a great community.

We welcome any type of contribution, not just code. You can help with:
*   **Reporting a bug**
*   **Discussing the current state of the code**
*   **Submitting a fix**
*   **Proposing new features**
*   **Becoming a maintainer**

## Getting Started

### Development Environment

To get started with the development environment, you'll need:
*   Ruby (see `.ruby-version` for the required version)
*   Bundler

1.  **Fork the repository** on GitHub.
2.  **Clone your fork** locally:
    ```bash
    git clone https://github.com/your-username/dlinked.git
    cd dlinked
    ```
3.  **Install dependencies** using Bundler:
    ```bash
    bundle install
    ```

### Running Tests

This project uses Minitest for testing. To run the full test suite, use the following command:

```bash
bundle exec rake test
```

This will also run SimpleCov to generate a code coverage report in the `coverage/` directory. When submitting a pull request, please ensure that your changes are covered by tests and that you maintain or increase the test coverage.

### Code Style

This project uses RuboCop to enforce a consistent code style. To check your code for style violations, run:

```bash
bundle exec rubocop
```

Many style violations can be automatically fixed by running:

```bash
bundle exec rubocop -A
```

Please ensure your code follows the project's style guidelines before submitting a pull request.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue on GitHub. Please include:
*   A clear and descriptive title.
*   A detailed description of the problem, including steps to reproduce it.
*   The expected behavior and what actually happened.
*   The version of DLinked and Ruby you are using.

### Submitting Changes (Pull Requests)

1.  Create a new branch for your changes:
    ```bash
    git checkout -b your-feature-branch-name
    ```
2.  Make your changes, and add or update tests as needed.
3.  Ensure the test suite passes (`bundle exec rake test`).
4.  Ensure your code passes the RuboCop checks (`bundle exec rubocop`).
5.  Commit your changes with a clear and descriptive commit message.
6.  Push your branch to your fork on GitHub:
    ```bash
    git push origin your-feature-branch-name
    ```
7.  Open a pull request from your fork to the main DLinked repository.
8.  In the pull request description, please explain the problem you are solving and the changes you have made.

## Code of Conduct

By participating in this project, you are expected to uphold our [Code of Conduct](CODE_OF_CONDUCT.md).

Thank you for your contribution!
