export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_rakecomplete() {
  COMPREPLY=($(compgen -W "`rake -s -T 2>/dev/null | awk '{{print $2}}'`" -- ${COMP_WORDS[COMP_CWORD]}))
  return 0
}

_capcomplete() {
  COMPREPLY=($(compgen -W "`cap  -T  2>/dev/null| awk '{{ if ( $3 ~ /\#/ ) print $2}}'`" -- ${COMP_WORDS[COMP_CWORD]}))
  return 0
}

_thorcomplete() {
  COMPREPLY=($(compgen -W "`THOR_COLUMNS=1000 thor -T 2>/dev/null| awk '{{ if ( $2 ~ /./ ) print $2}}'`" -- ${COMP_WORDS[COMP_CWORD]}))
  return 0
}

complete -o default -o nospace -F _rakecomplete rake
complete -o default -o nospace -F _capcomplete cap
complete -o default -o nospace -F _thorcomplete thor
