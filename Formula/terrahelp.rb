class Terrahelp < Formula
  desc "Tool providing extra functionality for Terraform"
  homepage "https://github.com/opencredo/terrahelp"
  url "https://github.com/opencredo/terrahelp/archive/v0.7.5.tar.gz"
  sha256 "bfcffdf06e1db075872a6283d1f1cc6858b8139bf10dd480969b419aa6fc01f7"
  license "Apache-2.0"
  head "https://github.com/opencredo/terrahelp.git", branch: "main"

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "be14ceca5a50701b09d86ccf224def6bc98f9151847240068d3667c6e62a47a5"
    sha256 cellar: :any_skip_relocation, big_sur:       "58044fae3de9a59f2420d65923e6d2619b91d026e45a1a6629699b11f9afa5be"
    sha256 cellar: :any_skip_relocation, catalina:      "e8edbc804fa080128c6fdad4182eae24e3679c846bb03cfc7c71b56bba1e983a"
    sha256 cellar: :any_skip_relocation, mojave:        "7ba4bc44de9efe372c14e80ecb0eeed2f6b634fb1e49fa66768db616200206b8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "632dc956328a9b506fe8942c524f540225bd2cdbe2e19d10655c89a4d7cba505"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-mod=vendor"
  end

  test do
    tf_vars = testpath/"terraform.tfvars"
    tf_vars.write <<~EOS
      tf_sensitive_key_1         = "sensitive-value-1-AK#%DJGHS*G"
    EOS

    tf_output = testpath/"tf.out"
    tf_output.write <<~EOS
      Refreshing Terraform state in-memory prior to plan...
      The refreshed state will be used to calculate this plan, but
      will not be persisted to local or remote state storage.

      ...

      <= data.template_file.example
          rendered:  "<computed>"
          template:  "..."
          vars.%:    "1"
          vars.msg1: "sensitive-value-1-AK#%DJGHS*G"

      Plan: 0 to add, 0 to change, 0 to destroy.
    EOS

    output = shell_output("cat #{tf_output} \| #{bin}/terrahelp mask --tfvars #{tf_vars}").strip

    assert_match("vars.msg1: \"******\"", output, "expecting sensitive value to be masked")
    refute_match(/sensitive-value-1-AK#%DJGHS\*G/, output, "not expecting sensitive value to be presentt")
  end
end
