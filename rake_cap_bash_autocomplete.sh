_rakecomplete() {
  COMPREPLY=($(compgen -W "`rake -s -T | awk '{{print $2}}'`" -- ${COMP_WORDS[COMP_CWORD]}))
  return 0
}

_capcomplete() {
  COMPREPLY=($(compgen -W "`cap  -T | awk '{{ if ( $3 ~ /\#/ ) print $2}}'`" -- ${COMP_WORDS[COMP_CWORD]}))
  return 0
}

cd () {
    command cd "$@";
    # Add enhanced completion for a folder containing a ruby env and remove it when we leave the folder                      
    if [ -f ./Rakefile ]; then
        complete -o default -o nospace -F _rakecomplete rake
    else
        complete -r rake  2>/dev/null
    fi

    # Add enhanced completion for a folder containing a capistrano env and remove it when we leave the folder                
    if [ -f ./Capfile ]; then
        complete -o default -o nospace -F _capcomplete cap
    else
        complete -r cap  2>/dev/null
    fi
}