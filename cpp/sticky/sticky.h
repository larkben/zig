#include <string>

struct Tasks {
    int id;
    std::string name;
    std::string description;
    bool completed;
};

class Sticky {
    private:
        int size;
        Tasks *tasks;
        int nextId;
    public:
        //* constructors
        Sticky();
        ~Sticky();
        
        //* methods
        void addTask();
        void removeTask(int id);
        void markTaskCompleted(int id);

        //* utility functions
        void printTasks();
        int getTaskCount();
};