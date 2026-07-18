#include <iostream>
#include <thread>
#include <mutex>
#include <atomic>
#include <condition_variable>

std::mutex mtx;
std::condition_variable cv;

void doWork(int &p, int &pc)
{
    while (true) {
        std::unique_lock<std::mutex> lock(mtx); // lock the mutex
        cv.wait(lock, [&] { return pc == 0; }); // wait for the condition variable to be notified

        if (p <= 0) {
            cv.notify_one();
            return; // exit the thread if there are no more people
        }

        pc = p; // update previous count
        p--; // decrement the number of people

        cv.notify_one(); // notify the main thread that work is done
    }
}

int main() {

    int people {10000000};
    int previousCount {};

    std::thread worker(doWork, std::ref(people), std::ref(previousCount)); // pass by reference

    while (true) {
        std::unique_lock<std::mutex> lock(mtx); // lock the mutex
        cv.wait(lock, [&] { return previousCount > 0 || people <= 0; }); // wait for the condition variable to be notified

        if (previousCount > 0) {
            if (previousCount > people) {
                std::cout << "Number of people left: " << people << std::endl;
            }
            previousCount = 0; // consumed
        }

        bool done = (people <= 0);
        cv.notify_one(); // wake worker so it can produce again or exit
        lock.unlock();

        if (done) break;
    }

    worker.join(); // wait for the thread to finish
    return 0;
}