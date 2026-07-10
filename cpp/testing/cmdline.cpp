#include <iostream>

//* capturing command line arguments in C++
int main(int argc, char* argv[]) {
    for (int i = 0; i < argc; ++i) {
        std::cout << "Argument " << i << ": " << argv[i] << std::endl;
    }

    int x {0};

    if (argv[1] == nullptr) {
        std::cout << "Zero arguments were passed to the program." << std::endl;
        std::cin >> x;
        std::cout << "You entered: " << x << std::endl;
    }

    return 0;
}