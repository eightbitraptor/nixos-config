function use-ruby
  if test -d "$HOME/.rubies/ruby-$argv[1]"
    set -gx PATH "$HOME/.rubies/ruby-$argv[1]/bin" $PATH
    echo "Using Ruby $argv[1]"
  else
    echo "Ruby $argv[1] not found"
    echo "Available versions:"
    ls $HOME/.rubies/
  end
end
