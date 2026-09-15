---
name: jenkins
description: "Jenkins core development and jenkinsci contribution: remoting/agent internals, REST accessors and @Exported patterns, PR etiquette (complete template, maintainer checklist, one open PR for newcomers), Maven build and targeted tests with the war staleness pitfall, ci.jenkins.io flaky tests, and agent provisioning flows (crumb, jnlp secret, inbound launch arguments). Use when editing jenkinsci/jenkins or remoting, opening or reworking a Jenkins PR, writing core tests with JenkinsRule, automating agent registration, or debugging controller REST 403/401."
license: MIT
compatibility: opencode
metadata:
  domain: ci-cd
  triggers: jenkins, jenkinsci, remoting, inbound agent, jnlp, jnlpMac, agent secret, @Exported, @Restricted, JenkinsRule, core-pr-reviewers, ci.jenkins.io, doCreateItem, crumbIssuer, agent.jar, LTS upgrade
  related-skills: ansible
---

# Jenkins core and jenkinsci contribution

Verified conventions from contributing to jenkinsci/jenkins (agent connection
secret exposure, JNLP warning rework). Facts were checked against sources,
not memory.

## jenkinsci PR etiquette

- Read the newcomer rules first: jenkinsci/jenkins#26359. One open pull
  request until it lands. Two same-topic PRs from a new contributor get both
  closed.
- The pull request description MUST use the COMPLETE template: Fixes line,
  Testing done with proof a computer ran the changed lines, Screenshots (N/A
  fine), Proposed changelog entries (imperative mood, no issue number inside),
  Proposed changelog category (/label rfe|bug|major-rfe...),
  Proposed upgrade guidelines (N/A allowed), Submitter checklist, Maintainer
  checklist (unchecked). Missing sections = closure by maintainers, even if
  the diff is good.
- Never @mention @jenkinsci/core-pr-reviewers unless the change needs an
  accelerated review. Merge needs 2 approvals. Maintainers run "update
  branch" themselves when master moves; expect a fresh CI run after their
  merge commit lands on your branch.
- CheckStyle, SpotBugs and the test gates must be green: fix locally before
  pushing (see build pitfalls below).
- Known ci.jenkins.io flaky tests, unrelated to your diff and worth a polite
  comment with references: `hudson.cli.Security3630Test.testConcurrentCliSessionPairing`
  on windows-jdk25 (#27087 tried to fix it, refs #4904) and
  `hudson.PluginManagerTest.doNotThrowWithUnknownPlugins` on linux-jdk21
  (#10238 debugged it). The aggregate "Jenkins" check reports Unstable for
  either.

## Java core patterns

- REST accessor: follow `SlaveComputer.getAbsoluteRemotePath()`: `@Exported`,
  `@Restricted(DoNotUse.class)`, `@CheckForNull`, with the permission check
  INSIDE the getter (`hasPermission(Computer.CONNECT)`) returning null
  otherwise. @since = current master version (grep the newest @since in tree).
- For secrets, prefer a dedicated WebMethod endpoint (like the pending
  /agent-secret in #26017) over @Exported: an exported field leaks into every
  generic /api/json response for permission holders; an endpoint is opt-in.
- jnlpMac is `JnlpAgentReceiver.SLAVE_SECRET.mac(nodeName)`, public but NOT
  @Exported: invisible to /api/json?tree even for administrators. Secret is
  deterministic per node, not stored per node.
- REST form POSTs (doCreateItem) need a CSRF crumb with basic auth +
  password. API tokens are exempt. Replay the crumb session cookie with the
  crumb header.
- JNLP descriptor: first argument is jnlpMac (64 hex), second is the node
  name. Launch style `-jnlpUrl` is deprecated and mutually exclusive with
  `-url/-name` (remoting `Launcher` forbids mixing). Modern inbound:
  `-url <controller>/ -name <name> -workDir <dir> -secret @file -webSocket`.
- Agent protocol changes to know: 2.440.1 deprecates -jnlpUrl, 2.479.1
  requires Java 17 (dropped later), 2.555.1 requires Java 21/25 and remoting
  >= 3176.v207ec082a_8c0 (older agents are refused, not warned), 2.568.x is
  the validated LTS here.

## Build and test pitfalls

- The `test` module resolves jenkins-war from ~/.m2, NOT from reactor source:
  after touching core, run the install first or your surefire run tests a
  stale jar. Symptoms: your fix "not applied" while git log shows it.
  Sequence:
  `mvn -pl war -am install -DskipTests -Dfrontend.skip=true -Denforcer.skip=true`
  then `mvn -pl test surefire:test -Dtest=YourTest -Dfrontend.skip=true -Denforcer.skip=true`.
- `-Dfrontend.skip=true` is mandatory: the parent pom runs a `yarn test`
  corepack goal that cannot be skipped by skip.frontend.
- No javac on the host (JRE only) breaks with "release version 21 not
  supported": use `mise x maven@3.9.11 java@21 -- mvn ...` (mise-managed JDK).
- CheckStyle: EmptyLineSeparatorCheck enforces a blank line between methods.
  Run `mvn -pl test checkstyle:check` locally before pushing; one new issue
  fails the CI aggregate.
- Shallow clone of jenkinsci/jenkins is fine for small PRs. JenkinsRule tests
  take ~40 s each on this machine; matrices on ci.jenkins.io are slower
  (queue) and windows runs can exceed 2 hours.
- htmlunit: `wc.goTo(url, contentType)` asserts the content type; the JNLP
  endpoint serves `application/x-java-jnlp-file` and returns a Page, chain
  `.getWebResponse()`.
- Log assertions: attach a `java.util.logging.Handler` to
  `Logger.getLogger(ClassUnderTest.class.getName())`, capture WARNING+,
  assert on messages, remove the handler in finally.

## Agent provisioning flow (what an automation tool does)

1. GET /computer/<name>/api/json (404 = not registered)
2. GET /crumbIssuer/api/json (crumb + session cookie; replay both)
3. POST /computer/doCreateItem?name=<n>&type=hudson.slaves.DumbSlave with
   form-urlencoded `json=<payload>`; payload uses the blank `""` key with the
   launcher/retentionStrategy class list and a PURE JNLPLauncher (no
   workDirSettings, no webSocket key)
4. GET /computer/<name>/jenkins-agent.jnlp (gated Agent/Connect; one false
   deprecation warning per fetch in controller logs)
5. GET /jnlpJars/agent.jar (force refresh; stale remoting < minimum is
   REFUSED by new controllers)
6. Run agent with -url/-name/-workDir/-secret @file/-webSocket; secret NEVER
   in argv (readable via WMI Win32_Process on Windows)
- Upstream: #16537 tracks a supported secret accessor, #26017 implements
  /agent-secret. Re-check when it ships in an LTS.
