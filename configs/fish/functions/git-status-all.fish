function git-status-all
  for dir in */
    if test -d "$dir/.git"
      echo -e "\n\033[1;34m$dir\033[0m"
      cd $dir
      git status -sb
      cd ..
    end
  end
end
