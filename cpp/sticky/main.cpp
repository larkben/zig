#include <iostream>
#include "sticky.h"

int main() {

    while (true) {

        std::cout << "Sticky Notes Application" << std::endl;
        std::cout << "1. Add Task" << std::endl;
        std::cout << "2. Remove Task" << std::endl;
        std::cout << "3. Mark Task Completed" << std::endl;
        std::cout << "4. Print Tasks" << std::endl;
        std::cout << "5. Exit" << std::endl;

        int choice;
        std::cout << "Enter your choice: ";
        std::cin >> choice;
        std::cin.ignore(); // Ignore the newline character after the choice input

        Sticky sticky;

        // clear the terminal screen
        // std::cout << "\033[2J\033[1;1H"; // clear the terminal screen

        switch (choice) {
            case 1:
                sticky.addTask();
                break;
            case 2: {
                int id;
                std::cout << "Enter task ID to remove: ";
                std::cin >> id;
                sticky.removeTask(id);
                break;
            }
            case 3: {
                int id;
                std::cout << "Enter task ID to mark as completed: ";
                std::cin >> id;
                sticky.markTaskCompleted(id);
                break;
            }
            case 4:
                sticky.printTasks();
                break;
            case 5:
                return 0;
            default:
                std::cout << "Invalid choice. Please try again." << std::endl;
        }
    }
    return 0;
}