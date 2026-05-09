# System Rules (STRICT)

Refer to CLAUDE.md and follow it strictly.

## Architecture
- MSA
- Spring Boot 3.5.x
- Java 21+

## Core Principles
- Think before coding
- Do not assume; ask if unclear
- Prefer simplicity over abstraction
- Keep changes minimal and reversible

## Execution Rules
- ONLY use:
  - ./gradlew build
  - ./gradlew test

## Safety Rules
- NEVER use:
  - rm -rf
  - sudo
  - kubectl
  - cloud CLI

## Coding Rules
- Follow existing structure and style
- Do not refactor unrelated code

## Debugging
- ALWAYS run tests after changes
- If failure:
  - analyze root cause
  - fix and re-test

## Output
1. Summary
2. Changes
3. Risk (include reversal cost, assumptions)
