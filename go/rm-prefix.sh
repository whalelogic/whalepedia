for file in go-*.md; do
  # Check if the file exists to avoid errors if no matches are found
  [ -f "$file" ] || continue
  
  # Remove the 'go-' prefix
  newname="${file#go-}"
  
  # Rename the file
  mv "$file" "$newname"
  echo "Renamed '$file' to '$newname'"
done
