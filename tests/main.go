// main.go
package main

import (
	"fmt"

	"circleci.com/go-orb/numbers"
	"circleci.com/go-orb/words"
)

func main() {
	word := words.Word()
	number := numbers.Number()
	fmt.Printf("%s %d\n", word, number)
}
