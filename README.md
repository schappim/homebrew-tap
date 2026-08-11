# schappim/homebrew-tap

Homebrew formulae for [Amplifier](https://amplifier.app).

```bash
brew install schappim/tap/amplifier-agent
```

## Formulae

### `amplifier-agent`

The [Amplifier session client](https://github.com/schappim/amplifier_client) —
runs Claude Code and Codex sessions on your own machine and streams them to the
Amplifier web app, so the browser becomes your terminal.

```bash
brew install schappim/tap/amplifier-agent
amplifier-agent setup --url https://amplifier.app --token paste-your-token-here
amplifier-agent                          # or: brew services start amplifier-agent
```

Copy the token from the app: **Claude Code** or **Codex** in the sidebar → your
machine → **Show token & setup**. Claude sessions use this machine's Claude Code
login, so run `claude` and sign in once first.

Full documentation, requirements, and security notes are in the
[client repo](https://github.com/schappim/amplifier_client).

## Releasing a new version

The formula is bumped by `agent/release.sh` in the application repo, which cuts
the release in `schappim/amplifier_client` and rewrites the `url` and `sha256`
here. There is no need to edit this repo by hand.
