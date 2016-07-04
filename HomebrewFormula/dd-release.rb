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

class TtRelease < Formula
  desc "DesmoDyne ReleaseTools for automating the release process."
  homepage "desmodyne.com"
  url "https://gitlab.com/DesmoDyne/Tools/ReleaseTools"
  head "https://gitlab.com/DesmoDyne/Tools/ReleaseTools", :branch => "feature/8/add_homebrew_tap_for_teamtools"
  version "tools"
  sha256 ""

  depends_on "cmake" => :build
  depends_on "coreutils" # realpath is part of coreutils
  depends_on "git-flow"
  depends_on "bash"
  
  def install
    system "cmake", "./build/", *std_cmake_args
    system "make", "install"
  end
end
