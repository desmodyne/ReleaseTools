# shellcheck shell=bash

# dd-rt-library.sh
#
# DesmoDyne ReleaseTools library of constants functions
#
# author  : stefan schablowski
# contact : stefan.schablowski@desmodyne.com
# created : 2019-07-13


# -----------------------------------------------------------------------------
# define constants


# --------------
# error messages

# error message displayed if user git configuration verification fails
# NOTE: this is (somewhat intentionally) identical to git native message
read -r -d '' err_msg_git_conf << 'EOT'

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.
EOT

# template for error message displayed when semver argument validation fails
read -r -d '' err_msg_git_conf << 'EOT'
version argument %s is not greater than existing version %sdefined in\n  %s
EOT

# TODO: doc differences between git-flow and git-flow-avh on Linux / macOS:
#
# message on Linux, 1.8.0 (AVH Edition) installed using aptitude install git-flow:
#   Fatal: Not a gitflow-enabled repo yet. Please run 'git flow init' first.
# message on OSX, version 0.4.1, installed using brew install git-flow:
#   fatal: Not a gitflow-enabled repo yet. Please run "git flow init" first.
# message on OSX, 1.9.1 (AVH Edition), installed using brew install git-flow-avh:
#   fatal: Not a gitflow-enabled repo yet. Please run "git flow init" first.

# the message of an expectable and recoverable error
read -r -d '' err_msg_git_flow_init << 'EOT'
Fatal: Not a gitflow-enabled repo yet. Please run 'git flow init' first."
EOT


# ----------------------
# git flow configuration

# message template for committing updated version to project conf file
commit_msg_version_tmpl='[#1]: update project version to %s'

# message template for committing release notes
commit_msg_release_tmpl='[#1]: add release notes for version %s'

# name of branch for next release development;
# 'develop' as per git flow convention
branch_develop='develop'

# name of branch for production releases;
# 'master' as per git flow convention
branch_master='master'

# name prefix of release branch;
# 'release' as per git flow convention
branch_release_prefix='release'

# name of default git repo remote
remote_default_name='origin'

# message for creating release tag
# TODO: research what this is good for
# TODO: add project and release names ?
# TODO: on OSX, getopt fails on spaces, even
# with extra / escaped single / double quotes:
# https://github.com/nvie/gitflow/issues/98
# TODO: does this also occur on on Linux ?
tag_message='automatically_created_release_tag'


# ------------------------------
# paths to folders and filenames

# path to project configuration file, relative to root of target project
path_to_target_conf='.releasetools.yaml'

# path to folder with release notes, relative to root of target project
path_to_release_notes='doc/md/Release Notes'

# name template for release notes file
release_notes_tmpl="%s Release Notes %s.md"


# ---------------------------
# regular and sed expressions

# regular expression that matches a semantic version:
# MAJOR.MINOR.PATCH versioning: http://semver.org
# https://en.wikipedia.org/wiki/Software_versioning
# NOTE: meant for use with grep or sed, does not work with bash;
# e.g. [[ '1.2.3' =~ ${semver_regex} ]] does not create a match
#
# TODO: review regular expression globally:
# e.g. \d is a Perlism
# e.g. [0-9] fails for locales other than C (or Western European)
# e.g. [[:digit:]] works for all theses cases
# http://stackoverflow.com/a/26091443
# TODO: semver also allows e.g. 1, 2.0, 3.0.* and others
regex_semver='^\([[:digit:]]\+\)\.\([[:digit:]]\+\)\.\([[:digit:]]\+\)$'

# TODO: use smarter git command and remove [*]

# regular expression to match branch name for
# next release development in 'git branch' output
regex_develop_local="^[ |*] ${branch_develop}$"

# same as above, but for remote branches
regex_develop_remote="^  ${remote_default_name}/${branch_develop}$"

# regular expression to match branch name for
# production releases in 'git branch' output
regex_master_local="^[ |*] ${branch_master}$"

# same as above, but for remote branches
regex_master_remote="^  ${remote_default_name}/${branch_master}$"

# GNU sed expression to get major from semver
sedex_semver_major='s|^\([0-9]\+\)\..*|\1|g'

# GNU sed expression to get minor from semver
sedex_semver_minor='s|^.*\.\([0-9]\+\)\..*$|\1|g'

# GNU sed expression to get patch from semver
sedex_semver_patch='s|.*\.\([0-9]\+\)$|\1|g'

# GNU sed expression template to match multi-line version in yaml conf file
# NOTE: this works on a file that has been prepared using tr '\n' '\r'
# NOTE: need to escape \r and \1, \2, etc. as this template gets printf'd
# NOTE: this uses Perl extended regular expression syntax
# https://unix.stackexchange.com/a/152389
# https://stackoverflow.com/a/152755
# https://stackoverflow.com/a/7167115 <-- hard to grok regex
# TODO: this assumes there are no comments within the version conf section
sedex_yaml_version_tmpl='s|'
sedex_yaml_version_tmpl+='\(version\s*:\s*\\r\)'
sedex_yaml_version_tmpl+='\(\s*major\s*:\s*\)%s\(\s*\\r\)'
sedex_yaml_version_tmpl+='\(\s*minor\s*:\s*\)%s\(\s*\\r\)'
sedex_yaml_version_tmpl+='\(\s*patch\s*:\s*\)%s\(\s*\\r\)'
sedex_yaml_version_tmpl+='|'
sedex_yaml_version_tmpl+='\\1'
sedex_yaml_version_tmpl+='\\2%s\\3'
sedex_yaml_version_tmpl+='\\4%s\\5'
sedex_yaml_version_tmpl+='\\6%s\\7'
sedex_yaml_version_tmpl+='|g'


# -------------------------
# other configuration items

# 'date' format for release notes timestamp
# TODO: add time to support multiple releases per day ?
release_notes_date_format='+%Y%m%d'


# -----------------------------------------------------------------------------
# define functions: http://stackoverflow.com/a/6212408

# TODO: remove duplicate code ?

function get_script_args
{
    echo -n 'get script arguments: '

    if [ $# -ne 1 ]
    then
        msg='ERROR'$'\n''wrong number of arguments'$'\n'$'\n'
        msg+="$(usage)"
        echo "${msg}" >&2
        return 1
    fi

    # http://stackoverflow.com/a/14203146
    while [ $# -gt 0 ]
    do
        key="${1}"

        case "${key}" in
            # NOTE: must escape -?, seems to act as wildcard otherwise
            -\?|--help)
            echo 'HELP'; echo; usage; return 1 ;;

            *)
            if [ -z "${repo_root}" ]
            then
                repo_root="${1}"
            else
                msg='ERROR'$'\n''wrong number of arguments'$'\n'$'\n'
                msg+="$(usage)"
                echo "${msg}" >&2
                return 1
            fi
        esac

        # move past argument or value
        shift
    done

    # repo root is a mandatory command line argument
    if [ -z "${repo_root}" ]
    then
        msg='ERROR'$'\n''wrong number of arguments'$'\n'$'\n'
        msg+="$(usage)"
        echo "${msg}" >&2
        return 1
    fi

    if ! output="$(git -C "${repo_root}" status)"
    then
        msg='ERROR'$'\n'"${output}"$'\n'
        echo "${msg}" >&2
        return 1
    fi

    if [ ! -d "${repo_root}/.git" ]
    then
        msg='ERROR'$'\n'"${repo_root}: "
        msg+="path is not the repository root folder, but a sub-folder"$'\n'
        echo "${msg}" >&2
        return 1
    fi

    echo 'OK'
    return 0
}


function get_script_args_opt_arg
{
    echo -n 'get script arguments: '

    if [ $# -ne 1 ] && [ $# -ne 2 ]
    then
        msg='ERROR'$'\n''wrong number of arguments'$'\n'$'\n'
        msg+="$(usage_opt_arg)"
        echo "${msg}" >&2
        return 1
    fi

    while [ $# -gt 0 ]
    do
        key="${1}"

        case "${key}" in
            -\?|--help)
            echo 'HELP'; echo; usage_opt_arg; return 1 ;;

            *)
            if [ -z "${repo_root}" ]
            then
                repo_root="${1}"
            else
                if [ -z "${semver}" ]
                then
                    semver="${1}"
                else
                    msg='ERROR'$'\n''wrong number of arguments'$'\n'$'\n'
                    msg+="$(usage_opt_arg)"
                    echo "${msg}" >&2
                    return 1
                fi
            fi
        esac

        shift
    done

    if [ -z "${repo_root}" ]
    then
        msg='ERROR'$'\n''wrong number of arguments'$'\n'$'\n'
        msg+="$(usage_opt_arg)"
        echo "${msg}" >&2
        return 1
    fi

    if ! output="$(git -C "${repo_root}" status)"
    then
        msg='ERROR'$'\n'"${output}"$'\n'
        echo "${msg}" >&2
        return 1
    fi

    if [ ! -d "${repo_root}/.git" ]
    then
        msg='ERROR'$'\n'"${repo_root}: "
        msg+="path is not the repository root folder, but a sub-folder"$'\n'
        echo "${msg}" >&2
        return 1
    fi

    if [ -n "${semver}" ]
    then
        if ! grep -q "${regex_semver}" <<< "${semver}"
        then
            msg='ERROR'$'\n'"${semver}: Invalid semantic version"$'\n'
            echo "${msg}" >&2
            return 1
        fi
    fi

    echo 'OK'
    return 0
}


function usage
{
    # https://stackoverflow.com/q/192319
    # https://stackoverflow.com/a/965072
    script_name="${0##*/}"

    # NOTE: indentation added here for improved readability
    # is stripped by sed when message is printed
    read -r -d '' msg_tmpl << EOT
    Usage: %s <target folder>

    mandatory arguments:
      target folder         git repository root folder of target project

    optional arguments:
      -?, --help            print this help message
EOT

    # NOTE: printf strips trailing newlines
    # shellcheck disable=SC2059
    msg="$(printf "${msg_tmpl}" "${script_name}" | sed -e 's|^    ||g')"$'\n'

    echo "${msg}"

    return 0
}


function usage_opt_arg
{
    # https://stackoverflow.com/q/192319
    # https://stackoverflow.com/a/965072
    script_name="${0##*/}"

    # NOTE: indentation added here for improved readability
    # is stripped by sed when message is printed
    read -r -d '' msg_tmpl << EOT
    Usage: %s <target folder> [version]

    mandatory arguments:
      target folder         git repository root folder of target project

    optional arguments:
      version               semantic project version to release
      -?, --help            print this help message
EOT

    # NOTE: printf strips trailing newlines
    # shellcheck disable=SC2059
    msg="$(printf "${msg_tmpl}" "${script_name}" | sed -e 's|^    ||g')"$'\n'

    echo "${msg}"

    return 0
}
