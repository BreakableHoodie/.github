# Security policy

This policy is inherited by every `BreakableHoodie` repository that does not
ship its own `SECURITY.md`.

## Reporting a vulnerability

**Use GitHub's private vulnerability reporting.** On the affected repository, go
to the **Security** tab → **Report a vulnerability**. That opens a private
advisory visible only to the maintainer, so the report and any fix can be
discussed before the details are public.

If that option is not visible on a repository, open a normal issue that says
only *"requesting a private channel for a security report"* — with **no
details** — and a private advisory will be opened to continue in.

**Please do not** put details in a public issue, pull request, discussion, or
commit message. That publishes a working report of the problem to everyone,
including before there is a fix.

## What to expect

These are personal projects maintained by one person, so this is a statement of
intent rather than a service-level agreement:

- An acknowledgement when the report is read, not necessarily immediately.
- An assessment of whether it is exploitable, and if so, roughly how severe.
- A fix prioritised over feature work, and credit in the advisory if you want it.

Reports that turn out not to be exploitable are still worth sending. A finding
that is wrong is cheap to dismiss; one that is never sent is not.

## Scope

In scope: anything that lets someone read or change data they should not,
impersonate another user, bypass authentication or authorisation, or take a
service down. Dependency vulnerabilities are in scope when a project actually
reaches the affected code path.

Out of scope: findings from automated scanners with no demonstrated impact,
missing hardening headers with no exploit path, social engineering, physical
access, and denial of service by sheer volume.

**Please do not test against production.** Several of these projects run live
services with real user data. Reproduce locally, or describe the issue and let
it be verified rather than demonstrated against a running system.
