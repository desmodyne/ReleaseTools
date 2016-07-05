# releasetools.rb
#
# ReleaseTools brew formula
#
# author  : stefan schablowski
# contact : stefan.schablowski@desmodyne.com
# created : 2016-06-06


# http://apple.stackexchange.com/a/97205
# https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/README.md
# https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/Formula-Cookbook.md
# https://github.com/Homebrew/brew/blob/master/share/doc/homebrew/How-to-Create-and-Maintain-a-Tap.md
# https://github.com/Homebrew/legacy-homebrew/tree/master/share/doc/homebrew
# http://formalfriday.club/2015/01/05/creating-your-own-homebrew-tap-and-formula.html


# TODO: find a way to align this file's project space location with convention


# NOTE: should be ReleaseTools,
#  but brew needs Releasetools
class Releasetools < Formula
  # TODO: get this from PackageDescription.txt
  desc "DesmoDyne ReleaseTools"
  # TODO: create wiki page and add link
  homepage "http://www.desmodyne.com"
  # TODO: distribute production version using archive,
  # e.g. url "https://example.com/foo-0.1.tar.gz"
  url "https://gitlab.com/DesmoDyne/Tools/ReleaseTools"
  # TODO: add sha256 sum
  sha256 ""
  # TODO: investigate ways to better deal with dev / feature branch versions
  head "https://gitlab.com/DesmoDyne/Tools/ReleaseTools", :branch => "feature/8/align_brew_deployment"
  # TODO: keep this in sync with CPACK_PACKAGE_VERSION_* in CMakeLists.txt
  version "0.1.4"

  # required to update default bash 3 to version 4
  depends_on "bash"
  # contains realpath and other GNU shell utilities
  depends_on "coreutils"
  # more in line with Linux versions than git-flow
  depends_on "git-flow-avh"

  # TODO: do this algorithmically ?
  # TODO: use path_to_mirror_folder or so ?
  def install
    bin.install "./data/mirror/usr/bin/dd-bump-patch-version"
    bin.install "./data/mirror/usr/bin/dd-create-debian-package"
    bin.install "./data/mirror/usr/bin/dd-create-release-notes"
    bin.install "./data/mirror/usr/bin/dd-finish-release"
    bin.install "./data/mirror/usr/bin/dd-lint-debian-package"
    bin.install "./data/mirror/usr/bin/dd-publish"
    bin.install "./data/mirror/usr/bin/dd-push-finished-release"
    bin.install "./data/mirror/usr/bin/dd-push-release-branch"
    bin.install "./data/mirror/usr/bin/dd-release"
    bin.install "./data/mirror/usr/bin/dd-start-release"
    bin.install "./data/mirror/usr/bin/dd-update-package-server"
    bin.install "./data/mirror/usr/bin/dd-upload"
    bin.install "./data/mirror/usr/bin/dd-upload-artifacts"
    bin.install "./data/mirror/usr/bin/dd-verify-user-configuration"
  end

  # TODO: test: https://github.com/Homebrew/brew/blob/master/share/doc/ ...
  #              ... homebrew/Formula-Cookbook.md#add-a-test-to-the-formula

end
