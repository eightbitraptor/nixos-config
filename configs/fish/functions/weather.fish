function weather
  curl -s "wttr.in/$argv[1]?format=3"
end
