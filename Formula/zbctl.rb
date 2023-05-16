class Zbctl < Formula
  desc "Zeebe CLI client"
  homepage "https://docs.camunda.io/docs/apis-clients/cli-client/index/"
  url "https://github.com/camunda/zeebe.git",
      tag:      "8.2.5",
      revision: "141a856f81627d1216c771960f4a0bc8b02b6b7e"
  license "Apache-2.0"
  head "https://github.com/camunda/zeebe.git", branch: "develop"

  # Upstream creates stable version tags (e.g., `v1.2.3`) before a release but
  # the version isn't considered to be released until a corresponding release
  # is created on GitHub, so it's necessary to use the `GithubLatest` strategy.
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "8fca7f55da6008b7e9cf604ed119d4053ec5ceeb8a966e7e87a94273c73ce143"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "8fca7f55da6008b7e9cf604ed119d4053ec5ceeb8a966e7e87a94273c73ce143"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "8fca7f55da6008b7e9cf604ed119d4053ec5ceeb8a966e7e87a94273c73ce143"
    sha256 cellar: :any_skip_relocation, ventura:        "6777c366d6e2838ada13625975ac7c2031ccdd15ac2a06ebec51ae0cd0332412"
    sha256 cellar: :any_skip_relocation, monterey:       "6777c366d6e2838ada13625975ac7c2031ccdd15ac2a06ebec51ae0cd0332412"
    sha256 cellar: :any_skip_relocation, big_sur:        "6777c366d6e2838ada13625975ac7c2031ccdd15ac2a06ebec51ae0cd0332412"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "4a4b3752e415541a7a85d9bfd77b15b245a6fcea557267399d846c5744d33f39"
  end

  depends_on "go" => :build

  def install
    commit = Utils.git_short_head
    chdir "clients/go/cmd/zbctl" do
      project = "github.com/camunda/zeebe/clients/go/v8/cmd/zbctl/internal/commands"
      ldflags = %W[
        -w
        -X #{project}.Version=#{version}
        -X #{project}.Commit=#{commit}
      ]
      system "go", "build", "-tags", "netgo", *std_go_args(ldflags: ldflags)

      generate_completions_from_executable(bin/"zbctl", "completion")
    end
  end

  test do
    # Check status for a nonexistent cluster
    status_error_message =
      "Error: rpc error: code = " \
      "Unavailable desc = connection error: " \
      "desc = \"transport: Error while dialing dial tcp 127.0.0.1:26500: connect: connection refused\""
    output = shell_output("#{bin}/zbctl status 2>&1", 1)
    assert_match status_error_message, output
    # Check version
    commit = stable.specs[:revision][0..7]
    expected_version = "zbctl #{version} (commit: #{commit})"
    assert_match expected_version, shell_output("#{bin}/zbctl version")
  end
end
