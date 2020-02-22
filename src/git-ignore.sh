#!/bin/sh

set -e

echo() {
  print -R "$@"
}

warn() {
  echo "$@" 1>&2
}

die() {
  e="$1"
  shift
  warn "$@"
  exit "$e"
}

find_gitignore() (
  while :
  do
    if [[ -d .git || -f .gitignore ]]
    then
      echo "$( env - "PATH=$PATH" pwd )/.gitignore"
      return 0
    fi
    [[ . -ef .. ]] && return 1
    cd ..
  done
)

name="$( basename "$0" .sh )"
usage="Usage: $name [-h] [-f FILE] pattern [pattern...]"
help="$usage

  -f FILE  operate on FILE
  -h       display this help"

file=
while getopts :f:h opt
do
  case "$opt" in
  (f)
    file="$OPTARG"
    ;;
  (h)
    die 0 "$help"
    ;;
  (:)
    warn "$name: Option '$OPTARG' requires an argument"
    die 100 "$usage"
    ;;
  (\?)
    warn "$name: Unknown option '$OPTARG'"
    die 100 "$usage"
    ;;
  esac
done
shift $(( OPTIND - 1 ))

if [[ -z "$file" ]]
then
  file="$( find_gitignore )" || die 1 "$name: Not inside a git repository"
fi

[[ -e "$file" ]] || touch "$file"

rm -f "$file{tmp}"
for line
do
  echo "$line"
done | cat "$file" - | sort -u | grep . > "$file{tmp}"

rm -f "$file{new}"
{
  grep -v '^!' < "$file{tmp}" || :
  grep '^!' < "$file{tmp}" || :
} > "$file{new}"
rm -f "$file{tmp}"

warn -n "Updating $file... "
if cmp -s "$file" "$file{new}"
then
  warn 'Nothing to do!'
else
  mv -f "$file{new}" "$file"
  warn 'Done!'
fi
rm -f "$file{new}"