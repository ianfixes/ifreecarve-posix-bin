#!/bin/sh
# prints yaml for a JSON file given as input

ruby -ryaml -rjson -e 'puts YAML.dump(JSON.parse(STDIN.read), indentation: 2)' < $1
