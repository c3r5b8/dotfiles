if status is-interactive
    set -g fish_greeting
    set -gx PATH $HOME/go/bin $PATH

    set -gx EDITOR nvim
    set -gx VISUAL nvim

    bind ctrl-h backward-kill-word

    alias ll='ls -lah'
    alias gs='git status'
    alias gco='git checkout'
    alias vim='nvim'
    alias top='btop'
    alias cat='bat'

    abbr gcm 'git commit -m'
    abbr .. 'cd ..'
    abbr ... 'cd ../..'

    function ssh --description 'Wrap ssh with TERM=xterm-256color'
        set -lx TERM xterm-256color
        command ssh $argv
    end

    function starship_transient_prompt_func
        starship module character
    end
    starship init fish | source
    enable_transience

    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
end
