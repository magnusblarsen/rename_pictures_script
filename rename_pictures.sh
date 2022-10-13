#!/bin/bash

#TODO: lav funktion til at finde similar_destinations

#TODO: start med at kalde en funktion som omdoeber alle filer til 1,2,3,...,

#TODO: check med forskellige tegn som | osv. i filnavne

home_folder=$(pwd)

for folder in "$@"; do
	echo "Looking in folder: $folder"
	cd "$folder"
	if [[ $? -ne 0 ]]; then
		echo "Couldn't look in folder: $folder... terminating script"
		exit 1
	fi

	
	sorted_files=$(find . -maxdepth 1 -type f | 
		grep -Ei '.*(jpg|jpeg|png|heic|mp4|mov)$' | 
		xargs -d '\n' stat -c "%y %n" | sort | 
		sed -E "s/^([0-9]{4}-[0-9]{2}-[0-9]{2}) ([0-9]{2}:[0-9]{2}:[0-9]{2}.[0-9]{9} (\+|\-)[0-9]{4}) \.\/(.*)$/\1|\4/")
	echo "done sorting files"

	IFS=$'\n'
	for file in $sorted_files; do
		current_folder=$(pwd)

		date=$(echo $file | sed -E "s/^([0-9]{4}-[0-9]{2}-[0-9]{2})\|(.*)$/\1/")
		filename=$(echo $file | sed -E "s/^([0-9]{4}-[0-9]{2}-[0-9]{2})\|(.*)$/\2/")
		extension=${filename##*.}

		new_filename="$date (0).$extension"
		
		current_destination="$current_folder/$filename"
		new_destination="$current_folder/$new_filename"

		similar_destinations=$(find . -maxdepth 1 -type f | 
			grep -Ei "\.\/$date \(0\)\.(jpg|jpeg|png|heic|mp4|mov)" | wc -l)

		if [[ $similar_destinations -gt 0 ]]
		then
			number=1
			changed_new_destination="$current_folder/$date ($number).$extension"

			similar_destinations=$(find . -maxdepth 1 -type f | 
				grep -Ei "\.\/$date \($number\)\.(jpg|jpeg|png|heic|mp4|mov)" | wc -l)

			# while [[ -f $changed_new_destination ]]
			while [[ $similar_destinations -gt 0 ]]
			do
				((number++))
				changed_new_destination="$current_folder/$date ($number).$extension"
				similar_destinations=$(find . -maxdepth 1 -type f | 
					grep -Ei "\.\/$date \($number\)\.(jpg|jpeg|png|heic|mp4|mov)" | wc -l)
			done

			mv "$current_destination" "$changed_new_destination"
		else
			mv "$current_destination" "$new_destination"
		fi
	done;
	unset IFS

	echo "Going back to starting-point"
	cd "$home_folder"
done;
