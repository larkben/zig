#include <iostream>
#include <cstring>
#include <vector>
#include "alligator.h"

int main() {

    Alligator alligator(1024, 10); // 1024 bytes per block, 10 blocks

    void* ptr1 = alligator.allocate();
    if (ptr1) {
        std::cout << "Allocated memory at: " << ptr1 << std::endl;
        alligator.deallocate(ptr1);
        std::cout << "Deallocated memory at: " << ptr1 << std::endl;
    } else {
        std::cout << "Failed to allocate memory." << std::endl;
    }

    return 0;
}