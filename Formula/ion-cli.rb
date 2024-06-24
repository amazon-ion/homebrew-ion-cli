# Format documentation:
# * https://docs.brew.sh/Formula-Cookbook
# * https://rubydoc.brew.sh/Formula
class IonCli < Formula
  desc "Command line tools for working with the Ion data format."
  homepage "https://github.com/amzn/ion-cli"
  license "Apache-2.0"

  # Allows installing unreleased changes with the --HEAD flag
  head "https://github.com/amazon-ion/ion-cli.git", branch: "master"

  # Latest release
  url "https://github.com/amazon-ion/ion-cli/archive/refs/tags/v0.6.1.tar.gz"
  sha256 "fa2e1b79d1f1707d5abd1b8e3540ecdaa609ab7ec4868d5a975a5d6aff38da03"
  version "0.6.1"

  depends_on "rust" => :build

  def install
    if build.head?
      system "cargo", "build", "--all-features" , "--release", "--bin", "ion"
    else
      system "cargo", "build", "--release", "--bin", "ion"
    end
    bin.install "target/release/ion"
  end

  test do
    if build.head?
      # Make sure that this version is pointing to HEAD
      assert_match("HEAD", "#{self.version}")
      # Head should support all features of `ion-cli`
      # Verify if `generate` subcommand exist on `beta` (`generate` is an experimental feature under `ion-cli`)
      assert_match("generate", shell_output("ion beta generate --help"))
      # Make an Ion schema file with simple type definition
      (testpath/"example.isl").write "type::{ name: foo, type: int }"
      # Generate code based on above schema file and assert that the exit status is 0 (successful)
      shell_output("ion beta generate --directory #{testpath} --schema example.isl --language java --namespace org.example")
    else
      # Make sure that `ion --version` outputs the expected version number
      assert_match("ion #{self.version}", shell_output("ion --version"))
      # Make a simple Ion file with a few values in it
      (testpath/"example.ion").write "foo true 5. null [1, 2, 3]"
      # Convert the file to binary Ion and assert that the exit status is 0 (successful)
      shell_output("ion dump --format binary -o ./example.10n ./example.ion")
      # Convert the binary Ion file back to text and look for the resolved symbol text `foo`
      assert_match("foo", shell_output("ion dump --format pretty ./example.10n"))
    end
  end
end
