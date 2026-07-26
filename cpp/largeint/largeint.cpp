#include "largeint.h"
#include <iostream>

//* constructors
largeint::largeint() {
    size = 0;
    digits = nullptr;
}

largeint::largeint(int n) {
    size = n;
    digits = new int[size];
}

largeint::largeint(const largeint &other) {
    size = other.size;
    digits = new int[size];
    for (int i = 0; i < size; i++) {
        digits[i] = other.digits[i];
    }
}

largeint::largeint(std::string n) {
    size = n.length();
    digits = new int[size];
    for (int i = 0; i < size; i++) {
        digits[i] = n[size - 1 - i] - '0';
    }
}

//* destructor
largeint::~largeint() {
    delete[] digits;
}

//* operators
largeint largeint::operator+(const largeint &other) const {
    // maxSize is the maximum size of the two largeInts
    int maxSize = std::max(size, other.size); 
    // creates a new largeint with size maxSize + 1 to hold the result
    largeint result(maxSize + 1);
    
    int carry = 0;

    for (int i = 0; i < maxSize; i++) {
        int sum = carry; // fetches the carry from the previous iteration

        if (i < size) sum += digits[i];
        if (i < other.size) sum += other.digits[i];

        result.digits[i] = sum % 10; // remainder is the digit to be stored in the result

        carry = sum / 10; // quotient is the carry for the next iteration
    }
    if (carry) {
        // if there's a carry left after the last addition, we store it in the next digit
        result.digits[maxSize] = carry;
    } else {
        // if there's no carry left after the last addition, we don't need to store it
        result.size--;
    }
    // return the result largeint
    return result;
}

largeint largeint::operator-(const largeint &other) const {
    // maxSize is the maximum size of the two largeInts
    int maxSize = std::max(size, other.size); 
    // creates a new largeint with size maxSize to hold the result
    largeint result(maxSize);
    
    int borrow = 0;

    for (int i = 0; i < maxSize; i++) {
        int diff = borrow; // fetches the borrow from the previous iteration

        if (i < size) diff += digits[i];
        if (i < other.size) diff -= other.digits[i];

        if (diff < 0) {
            diff += 10; // if the difference is negative, we need to borrow from the next digit
            borrow = -1; // set borrow to -1 for the next iteration
        } else {
            borrow = 0; // reset borrow to 0 for the next iteration
        }

        result.digits[i] = diff;
    }
    // remove leading zeros from the result
    while (result.size > 1 && result.digits[result.size - 1] == 0) {
        result.size--;
    }
    // return the result largeint
    return result;
}

//* utility
void largeint::print() {
    for (int i = size - 1; i >= 0; i--) {
        std::cout << digits[i];
    }
    std::cout << std::endl;
}