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


# message displayed if user git configuration verification fails
# NOTE: this is (somewhat intentionally) identical to git native message
read -r -d '' error_message_git_conf << 'EOT'

*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.
EOT


# path to project configuration file, relative to root of target project
path_to_target_conf='.releasetools.yaml'


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
