class ExponentialAgent < Formula
  desc "Run Claude Code and Codex sessions on this machine, driven from Amplifier"
  homepage "https://github.com/schappim/amplifier_client"
  url "https://github.com/schappim/amplifier_client/releases/download/v1.0.0/exponential-agent-1.0.0.tar.gz"
  sha256 "2bc5f351884c02a8277e4b33e6406fd27d1858715365f5903f3dc8810862dd12"
  license "MIT"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  service do
    run [opt_bin/"exponential-agent"]
    keep_alive true
    log_path var/"log/exponential-agent.log"
    error_log_path var/"log/exponential-agent.log"
    # launchd hands the job a bare PATH. The agent shells out to Claude Code and
    # Codex, which in turn reach for git, node and whatever the session's project
    # needs, so seed it with the usual prefixes rather than letting sessions fail
    # with "command not found" in ways that look like app bugs. ~/.local/bin is
    # where Claude Code's native installer puts `claude`, and it is not in
    # std_service_path_env; without it a backgrounded agent can register fine and
    # then fail every session it is asked to start.
    environment_variables PATH: "#{Dir.home}/.local/bin:#{std_service_path_env}:/usr/local/bin"
  end

  def caveats
    <<~EOS
      Save your connector token once (copy it from Amplifier: Claude Code or Codex
      in the sidebar -> your machine -> "Show token & setup"):

        exponential-agent setup --url https://amplifier.app --token <your token>

      Then run it in a terminal:

        exponential-agent

      ...or in the background, starting at login:

        brew services start exponential-agent

      Claude sessions use this machine's Claude Code login, so run `claude` and
      sign in once before starting a session. Codex sessions use the Codex CLI
      login or CODEX_API_KEY.
    EOS
  end

  test do
    # No token configured anywhere, so the agent must refuse to start rather than
    # silently connecting to something. HOME is sandboxed during `brew test`, so
    # this cannot pick up a real config file.
    output = shell_output("#{bin}/exponential-agent 2>&1", 1)
    assert_match "AGENT_TOKEN is required", output

    assert_equal version.to_s, shell_output("#{bin}/exponential-agent --version").strip

    # `setup` has to write credentials somewhere only the owner can read.
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    system bin/"exponential-agent", "setup", "--url", "https://example.com", "--token", "test-token"
    config = testpath/"config/exponential-agent/config.json"
    assert_path_exists config
    assert_equal "100600", config.stat.mode.to_s(8)
    assert_match "https://example.com", config.read
  end
end
