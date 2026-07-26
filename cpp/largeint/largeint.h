#include <string>

class largeint {
    private:
        int size;
        int *digits;
    public:
        //* constructors
        largeint();
        largeint(int n);
        largeint(const largeint &other);
        largeint(std::string n);
        ~largeint();

        //* operators
        largeint operator+(const largeint &other) const;
        largeint operator-(const largeint &other) const;
        largeint operator*(const largeint &other) const;
        largeint operator/(const largeint &other) const;

        //* utility functions
        void print();

};