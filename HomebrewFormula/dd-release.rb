# dd-release.rb
#
# formula to install the dd-release tools on host
#
# author  : stefan schablowski
# contact : stefan.schablowski@desmodyne.com
# created : 2016-06-06
#
# Documentation: https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Formula-Cookbook.md
#                http://www.rubydoc.info/github/Homebrew/brew/master/Formula
# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!

class TtRelease < Formula
  desc "DesmoDyne ReleaseTools for automating the release process."
  homepage "desmodyne.com"
  url "https://gitlab.com/DesmoDyne/Tools/ReleaseTools"
  version "tools"
  sha256 ""

  depends_on "cmake" => :build
  depends_on "coreutils" # realpath is part of coreutils
  depends_on "git-flow"
  depends_on "bash"
  
  def install
    # ENV.deparallelize  # if your formula fails when building in parallel

    system "cmake", "./build/", *std_cmake_args
    system "make", "install"
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test release`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end
