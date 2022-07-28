# .............................................................................
# if terraform is available, create some custom aliases
# .............................................................................
command -v terraform >/dev/null && return

alias tf='terraform'
alias tfp='terraform plan'
alias tfa='terraform apply'
