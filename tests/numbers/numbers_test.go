package numbers

import "testing"

func TestNumber(t *testing.T) {
	result := Number()
	if result != 1987 {
		t.FailNow()
	}
}
