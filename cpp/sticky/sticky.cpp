#include <iostream>
#include "sticky.h"

Sticky::Sticky() {
    size = 0;
    tasks = nullptr;
    nextId = 1;
}

Sticky::~Sticky() {
    delete[] tasks;
}

void Sticky::addTask() {
    std::string name, description;
    std::cout << "Enter task name: ";
    std::getline(std::cin, name);
    std::cout << "Enter task description: ";
    std::getline(std::cin, description);

    Tasks *newTasks = new Tasks[size + 1];
    for (int i = 0; i < size; ++i) {
        newTasks[i] = tasks[i];
    }
    newTasks[size].id = nextId++;
    newTasks[size].name = name;
    newTasks[size].description = description;
    newTasks[size].completed = false;

    delete[] tasks;
    tasks = newTasks;
    size++;
}

void Sticky::removeTask(int id) {
    int index = -1;
    for (int i = 0; i < size; ++i) {
        if (tasks[i].id == id) {
            index = i;
            break;
        }
    }
    if (index == -1) {
        std::cout << "Task with ID " << id << " not found." << std::endl;
        return;
    }

    Tasks *newTasks = new Tasks[size - 1];
    for (int i = 0, j = 0; i < size; ++i) {
        if (i != index) {
            newTasks[j++] = tasks[i];
        }
    }

    delete[] tasks;
    tasks = newTasks;
    size--;
}  

void Sticky::markTaskCompleted(int id) {
    for (int i = 0; i < size; ++i) {
        if (tasks[i].id == id) {
            tasks[i].completed = true;
            return;
        }
    }
    std::cout << "Task with ID " << id << " not found." << std::endl;
}

void Sticky::printTasks() {
    for (int i = 0; i < size; ++i) {
        std::cout << "ID: " << tasks[i].id << ", Name: " << tasks[i].name
                  << ", Description: " << tasks[i].description
                  << ", Completed: " << (tasks[i].completed ? "Yes" : "No") << std::endl;
    }
}

int Sticky::getTaskCount() {
    std::cout << "Total tasks: " << size << std::endl;
    return size;
}