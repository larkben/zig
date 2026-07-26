#include <iostream>
#include "largeint.h"

// we don't use std namespace std;

template <typename T>
void print(T v) {
    std::cout << v << std::endl;
};

int main() {

    print("Testing largeint class...");
    print(5 + 10);

    return 0;
}