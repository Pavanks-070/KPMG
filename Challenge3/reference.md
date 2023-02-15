Below is the function where you pass in the object and a key and get back the value. 

Here's an example function that takes the object and key as arguments, and returns the value associated with the key:

javascript

get_value() { echo $1 | jq -r ".$2" }

You can use this function like this:

object='{"a":{"b":{"c":"d"}}}' key='a/b/c' value=$(get_value "$object" "$key") echo "$value"

output:

d
