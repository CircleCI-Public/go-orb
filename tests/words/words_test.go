package words

import "testing"

func TestWord(t *testing.T) {
	result := Word()
	if result != "Word" {
		t.FailNow()
	}
}
