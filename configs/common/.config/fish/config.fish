if status is-interactive
    set -gx PATH $HOME/go/bin $HOME/.local/bin $PATH

    set -gx GOROOT "$HOME/.go"
    fish_add_path "$GOROOT/bin"

    set -gx GOPATH "$HOME/.local/share/go"
    set -gx GOBIN "$HOME/.local/bin"
    fish_add_path "$GOBIN"

    mkdir -p "$GOPATH/src" "$GOBIN"

    set -gx EDITOR nvim
    set -gx VISUAL nvim

    set -g fish_greeting
    set -g fish_color_autosuggestion brblack
    set -g fish_color_cancel -r
    set -g fish_color_command green
    set -g fish_color_comment brblack
    set -g fish_color_cwd green
    set -g fish_color_cwd_root red
    set -g fish_color_end green
    set -g fish_color_error brred
    set -g fish_color_escape brcyan
    set -g fish_color_history_current --bold
    set -g fish_color_host normal
    set -g fish_color_host_remote yellow
    set -g fish_color_normal normal
    set -g fish_color_operator brcyan
    set -g fish_color_param cyan
    set -g fish_color_quote yellow
    set -g fish_color_redirection cyan --bold
    set -g fish_color_search_match white --background=brblack --bold
    set -g fish_color_selection white --background=brblack --bold
    set -g fish_color_status red
    set -g fish_color_user brgreen
    set -g fish_color_valid_path --underline
    set -g fish_key_bindings fish_default_key_bindings
    set -g fish_pager_color_background
    set -g fish_pager_color_completion normal
    set -g fish_pager_color_description yellow -i
    set -g fish_pager_color_prefix normal --bold --underline
    set -g fish_pager_color_progress brwhite --background=cyan --bold
    set -g fish_pager_color_secondary_background
    set -g fish_pager_color_secondary_completion
    set -g fish_pager_color_secondary_description
    set -g fish_pager_color_secondary_prefix
    set -g fish_pager_color_selected_background -r
    set -g fish_pager_color_selected_completion
    set -g fish_pager_color_selected_description
    set -g fish_pager_color_selected_prefix

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
