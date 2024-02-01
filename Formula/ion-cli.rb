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
  url "https://github.com/amzn/ion-cli/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "54c5a4bec9c833f273b15c101e55ec8affa0c672324c36e2b219e5b9f80c7744"
  version "0.5.0"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "--release", "--bin", "ion"
    bin.install "target/release/ion"
  end

  test do
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
