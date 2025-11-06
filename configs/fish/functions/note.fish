function note
  if test (count $argv) -eq 0
    cat ~/notes.md
  else
    echo $argv >> ~/notes.md
    echo "Note added"
  end
end
