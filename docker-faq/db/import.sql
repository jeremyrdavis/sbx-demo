-- Seed data for the FAQ app: Docker Sandboxes questions.
-- Loaded automatically by the postgres entrypoint after 01_schema.sql.

INSERT INTO faqs (question, answer, category, sort_order) VALUES

-- basics
(
    'What is Docker Sandboxes?',
    'Docker Sandboxes runs AI coding agents inside isolated microVMs so they can execute code, install packages, and use tools without touching your host. Each sandbox gets its own kernel, filesystem, Docker Engine, and network path, and your project directory is mounted in at the same absolute path it has on your host.',
    'basics',
    10
),
(
    'What are kits?',
    'A kit is a single spec.yaml file that declares what a sandbox can use: tools to install, files to drop in, environment variables, credentials to inject, network rules, and startup commands. Mixin kits (kind: mixin) add capabilities to an existing agent and stack together, while sandbox kits (kind: sandbox) define a whole agent from scratch. Kits are an experimental feature, so the format and commands may still change.',
    'basics',
    20
),
(
    'Can the agent build and run containers inside a sandbox?',
    'Yes. Every sandbox has its own Docker Engine with no path to the daemon on your host, so the agent can build images and start containers freely. That daemon state, image cache, and any installed packages persist across sandbox restarts, but nothing is shared between sandboxes.',
    'basics',
    30
),

-- security
(
    'How does credential injection keep my API keys out of the sandbox?',
    'An HTTP/HTTPS proxy on your host intercepts every outbound request, looks up the matching credential in your OS keychain, and overwrites the auth header before forwarding it. The real value never enters the VM — the agent only ever sees a sentinel such as proxy-managed. You provide values on the host with `sbx secret set`, and the agent or kit declares which service and header each request matches.',
    'security',
    40
),
(
    'What is clone mode?',
    'By default the sandbox mounts your working tree read-write, so the agent edits your files in place. Creating a sandbox with `--clone` turns on workspace isolation instead: the agent works on a private Git clone inside the VM and your repository is mounted read-only at /run/sandbox/source. The mode is fixed at creation time, and because the in-VM clone is deleted with the sandbox, commits you want to keep must be pushed or fetched first.',
    'security',
    50
),
(
    'Do my files change on the host while the agent works?',
    'In the default direct mode, yes — workspace edits are live on your host as the agent makes them. That includes files that run implicitly during normal development, such as Git hooks, CI configuration, Makefiles, and package.json scripts, so review changes before running any modified code. Git hooks live in .git/ and never show up in `git diff`, so check them separately.',
    'security',
    60
),

-- networking
(
    'How does network access work in a sandbox?',
    'All HTTP and HTTPS traffic from a sandbox leaves through a proxy on your host, which applies your policy rules to every request. The policy is deny-by-default: a domain is blocked unless a rule allows it, and blocked requests come back as HTTP 403 with an explanation. Raw TCP can be allowed per destination IP and port, while UDP and ICMP are blocked at the network layer and cannot be re-enabled with policy rules.',
    'networking',
    70
),
(
    'What are the three network policy presets?',
    'The first time the daemon starts (and after `sbx policy reset`) it asks you to pick one. Open allows all outbound traffic, equivalent to `sbx policy allow network "**"`. Balanced is deny-by-default with a baseline allowlist covering AI provider APIs, package managers, code hosts, container registries, and common cloud services. Locked Down blocks everything, including model provider APIs, until you allow it yourself.',
    'networking',
    80
),
(
    'How do I allow a domain that a sandbox cannot reach?',
    'Run `sbx policy allow network <domain>` on your host to add an allow rule on top of the active preset; add `--sandbox <name>` to scope it to one sandbox instead of all of them. Changes take effect immediately, and `sbx policy ls` shows the active rules while `sbx policy log` shows what was recently blocked and why. If your organization manages policy centrally, org rules replace local ones and `sbx policy allow` has no effect.',
    'networking',
    90
),
(
    'How do I reach a service running inside a sandbox?',
    'Sandbox ports are not exposed to your host automatically. Publish one from the host with `sbx ports <sandbox-name> --publish 8080:8080/tcp`, then run the same command without flags to list what is published. The service has to listen on all interfaces (0.0.0.0 or ::) rather than only 127.0.0.1 for the published port to work.',
    'networking',
    100
);
