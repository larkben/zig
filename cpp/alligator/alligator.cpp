#include <iostream>
#include <cstring>
#include <vector>
#include "alligator.h"

Alligator::Alligator(size_t blockSize, size_t blockCount): memoryBlockSize(blockSize), memoryBlockCount(blockCount) {
    memory = new char[memoryBlockSize * memoryBlockCount];
    memoryBlockUsage.resize(memoryBlockCount, false);
}

Alligator::~Alligator() {
    delete[] memory;
}

void* Alligator::allocate() {
    for (size_t i = 0; i < memoryBlockCount; ++i) {
        if (!memoryBlockUsage[i]) {
            memoryBlockUsage[i] = true;
            return static_cast<void*>(memory + i * memoryBlockSize);
        }
    }
    return nullptr; // No available memory blocks
}

void Alligator::deallocate(void* ptr) {
    if (ptr == nullptr) return;

    size_t index = (static_cast<char*>(ptr) - memory) / memoryBlockSize;
    if (index < memoryBlockCount && memoryBlockUsage[index]) {
        memoryBlockUsage[index] = false;
    }
}