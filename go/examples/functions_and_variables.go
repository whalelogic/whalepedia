package main

import (
	"errors"
	"fmt"
)

const (
	pi      = 3.14159
	project = "FieldGuides"
)

func add(x, y int) int {
	return x + y
}

func divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("division by zero")
	}
	return a / b, nil
}

func sum(nums ...int) int {
	total := 0
	for _, n := range nums {
		total += n
	}
	return total
}

func apply(a, b int, op func(int, int) int) int {
	return op(a, b)
}

func counter(start int) func() int {
	value := start
	return func() int {
		value++
		return value
	}
}

func main() {
	var name string
	name = "Go"

	var goVersion = 1.22
	x, y := 10, 20
	active := true

	fmt.Printf("Hello, %s (%s examples)\n", name, project)
	fmt.Printf("Version: %.2f\n", goVersion)
	fmt.Printf("x=%d y=%d active=%t\n", x, y, active)
	fmt.Printf("Pi constant: %.5f\n", pi)

	fmt.Printf("add(42, 13) = %d\n", add(42, 13))
	fmt.Printf("sum(1, 2, 3, 4) = %d\n", sum(1, 2, 3, 4))

	quotient, err := divide(10, 2)
	if err != nil {
		fmt.Println("divide(10,2) error:", err)
	} else {
		fmt.Printf("divide(10, 2) = %.2f\n", quotient)
	}

	_, err = divide(10, 0)
	if err != nil {
		fmt.Println("divide(10,0) error:", err)
	}

	multiply := func(a, b int) int {
		return a * b
	}
	fmt.Printf("apply(6, 7, multiply) = %d\n", apply(6, 7, multiply))

	next := counter(100)
	fmt.Printf("counter values: %d %d %d\n", next(), next(), next())
}
