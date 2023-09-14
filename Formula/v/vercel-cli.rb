require "language/node"

class VercelCli < Formula
  desc "Command-line interface for Vercel"
  homepage "https://vercel.com/home"
  url "https://registry.npmjs.org/vercel/-/vercel-32.2.3.tgz"
  sha256 "8d03d4efea10bb5f294d650f93dab7f641afa43c4755b3fda6232a5e2be4576c"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "d8ad77eaf33a16d3ed7875bed14b2c0aad5967e6c064d7210bb992bf96b71be9"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "d8ad77eaf33a16d3ed7875bed14b2c0aad5967e6c064d7210bb992bf96b71be9"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "d8ad77eaf33a16d3ed7875bed14b2c0aad5967e6c064d7210bb992bf96b71be9"
    sha256 cellar: :any_skip_relocation, ventura:        "d55dc7d5c70f678feeca54c48400ab4973981cc96a76191f64e78d9d06b1ff05"
    sha256 cellar: :any_skip_relocation, monterey:       "d55dc7d5c70f678feeca54c48400ab4973981cc96a76191f64e78d9d06b1ff05"
    sha256 cellar: :any_skip_relocation, big_sur:        "d55dc7d5c70f678feeca54c48400ab4973981cc96a76191f64e78d9d06b1ff05"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "bba176c1288923a10777bed21d731c60234c4db5662cc0d7e111d45c1c9672cc"
  end

  depends_on "node"

  def install
    inreplace "dist/index.js", "= getUpdateCommand",
                               "= async()=>'brew upgrade vercel-cli'"
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]

    # Remove incompatible deasync modules
    os = OS.kernel_name.downcase
    arch = Hardware::CPU.intel? ? "x64" : Hardware::CPU.arch.to_s
    node_modules = libexec/"lib/node_modules/vercel/node_modules"
    node_modules.glob("deasync/bin/*")
                .each { |dir| dir.rmtree if dir.basename.to_s != "#{os}-#{arch}" }

    # Replace universal binaries with native slices
    deuniversalize_machos
  end

  test do
    system "#{bin}/vercel", "init", "jekyll"
    assert_predicate testpath/"jekyll/_config.yml", :exist?, "_config.yml must exist"
    assert_predicate testpath/"jekyll/README.md", :exist?, "README.md must exist"
  end
end
