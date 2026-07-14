#include <iostream>
#include <thread>
#include <mutex>
#include <atomic>

std::mutex mtx;

void doWork(int &p, int &pc)
{
    while (p > 0) {
        std::lock_guard<std::mutex> lock(mtx); // lock the mutex
        if (pc == 0) {
            pc = p; // update previous count
            p--;
        }
    }
}

int main() {

    int people {1000000};
    int previousCount {};

    std::thread worker(doWork, std::ref(people), std::ref(previousCount)); // pass by reference

    while (people > 0) {
        std::lock_guard<std::mutex> lock(mtx); // lock the mutex
        if (previousCount > people) {
            std::cout << "Number of people left: " << people << std::endl;
        }
        previousCount = 0; // reset previous count
    }

    worker.join(); // wait for the thread to finish
    
    return 0;
}