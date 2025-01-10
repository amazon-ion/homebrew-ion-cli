# Format documentation:
# * https://docs.brew.sh/Formula-Cookbook
# * https://rubydoc.brew.sh/Formula
class IonCli < Formula
  desc "Command line tools for working with the Ion data format."
  homepage "https://github.com/amazon-ion/ion-cli"
  license "Apache-2.0"

  # Allows installing unreleased changes with the --HEAD flag
  head "https://github.com/amazon-ion/ion-cli.git", branch: "main"

  # Latest release
  url "https://api.github.com/repos/amazon-ion/ion-cli/tarball/v0.11.0"
  sha256 "e8adc6c58138c22e0f307ad292c926485615f17ef94290a1c3bb9d7cd87857bb"
  version "0.11.0"

  depends_on "rust" => :build

  def install
    system "cargo", "build", "--release", "--bin", "ion"
    bin.install "target/release/ion"
  end

  test do
    # Make a simple Ion file with a few values in it
    (testpath/"example.ion").write "foo true 5. null [1, 2, 3]"
    # Convert the file to binary Ion and assert that the exit status is 0 (successful)
    shell_output("ion cat --format binary -o ./example.10n ./example.ion")
    # Convert the binary Ion file back to text and look for the resolved symbol text `foo`
    assert_match("foo", shell_output("ion cat --format pretty ./example.10n"))
  end
end
