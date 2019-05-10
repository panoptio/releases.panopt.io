# Load the correct aliases file depending on which OS we're on.
if [[ "$OSTYPE" =~ '^darwin' ]]; then
	export PATH=${PATH}:/usr/local/bin
fi
