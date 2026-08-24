---
name: flask-fastapi
description: >
  Build Python HTTP services with Flask or FastAPI: routing, dependency
  injection, request/response models, async endpoints, error handlers, config
  per environment, and test clients. Use when the project uses Flask, FastAPI,
  Starlette, or when choosing between them; framework internals covered by
  context7 docs.
---

# Flask and FastAPI services

## Choosing

- FastAPI: async I/O, automatic OpenAPI, Pydantic validation, typed DI. Default for new APIs.
- Flask: sync simplicity, huge extension ecosystem (admin, auth), WSGI deployments. Default when extensions decide.

## Structure (both)

- Application factory pattern (`create_app()`); no import-time side effects.
- Routers/blueprints per resource domain; one file per router when it stays under ~300 lines.
- Schemas/models in their own module; routes stay thin, business logic in service functions.
- Config from environment (12-factor); a `Settings` object (pydantic-settings or similar) is the single source.

## FastAPI specifics

- Dependencies via `Depends`; DB sessions as yield-dependencies with cleanup.
- Response models on every route (`response_model=`) to control the contract.
- Pydantic v2: `model_config`, field validators; never hand-parse query/body.
- Async endpoints only when doing async I/O; blocking calls go through `run_in_executor`/`asyncio.to_thread`.
- Raise `HTTPException` at the edge; domain errors translated by exception handlers.

## Flask specifics

- Blueprints + `url_for`; app context (`current_app`, `g`) not globals.
- Marshmallow/pydantic for input validation before controllers touch data.
- Extensions initialized with `init_app(app)` inside the factory.

## Testing

- `httpx.AsyncClient` (FastAPI) or Flask `test_client` against the app factory.
- Test through the HTTP surface: status codes, JSON shape, auth paths.
- Override dependencies (FastAPI `dependency_overrides`) instead of monkeypatching internals.

## Anti-patterns

- Global mutable state (module-level DB clients).
- Business logic inside route functions.
- Sync drivers inside async routes.
- Skipping response models because "it works".
