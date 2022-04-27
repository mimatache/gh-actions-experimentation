package main_test

import "testing"

func Test_Math(t *testing.T) {
	if 2+2 != 4 {
		t.Error("Gi back boys, we've failed!")
		t.Fail()
	}
}
