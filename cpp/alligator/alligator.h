#include <iostream>
#include <vector>
#include <cstring>

// custom allocator for cpp
class Alligator {
    private:
        char* memory;
        size_t memoryBlockSize;
        size_t memoryBlockCount;
        std::vector<bool> memoryBlockUsage;
    public:
        Alligator(size_t blockSize, size_t blockCount);
        ~Alligator();
        void* allocate();
        void deallocate(void* ptr);
};