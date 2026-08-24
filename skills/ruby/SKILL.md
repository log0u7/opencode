---
name: ruby
description: >
  Write and review Ruby and Ruby on Rails code following community style
  guides, plus RSpec testing patterns. Use for any Ruby/Rails task. Detailed
  references live in the vendored ruby-rails-rspec-skill repo: read
  `~/.config/opencode/skills/ruby-rails/ruby-skill.md` (Ruby style, Rails
  conventions) and `~/.config/opencode/skills/ruby-rails/rspec-skill.md`
  (RSpec patterns), with deep dives under their `references/` directories.
---

# Ruby and Rails

## Quick rules

- Ruby style: rubystyle.guide. Two-space indent, `snake_case`, predicate methods end in `?`, bang methods only when a non-bang twin exists.
- Rails conventions: rails.rubystyle.guide. Fat models over fat controllers, but extract service objects when a model grows past its persistence role.
- Migrations are reversible (`change` with supported helpers); validate schema-changing plans against production data size.
- Security: strong parameters everywhere; no string-interpolated SQL; `ActiveSupport::Concern` sparingly.

## Workflow

1. Read the two reference files listed above before writing substantial code.
2. Follow their conventions exactly; they override generic habits.
3. Tests: RSpec patterns from `rspec-skill.md`; FactoryBot traits, request specs for API surface.
4. For current gem/framework API details, use context7 (Ruby on Rails docs).

## Version discipline

- Target the Ruby and Rails versions declared in the project Gemfile; do not suggest syntax newer than the floor.
