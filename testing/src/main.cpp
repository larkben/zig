#include <iostream>
#include <string>
#include <vector>
#include <map>
#include <iomanip>

using namespace std;

// --- Account Class ---
class Account {
private:
    int accountNumber;
    string accountHolderName;
    double balance;

public:
    Account() : accountNumber(0), accountHolderName(""), balance(0.0) {}
    
    Account(int accNum, string name, double initialDeposit) {
        accountNumber = accNum;
        accountHolderName = name;
        balance = initialDeposit;
    }

    void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
            cout << "Successfully deposited $" << fixed << setprecision(2) << amount << endl;
        } else {
            cout << "Invalid deposit amount!" << endl;
        }
    }

    bool withdraw(double amount) {
        if (amount > balance) {
            cout << "Insufficient funds! Current balance: $" << balance << endl;
            return false;
        } else if (amount <= 0) {
            cout << "Invalid withdrawal amount!" << endl;
            return false;
        } else {
            balance -= amount;
            cout << "Successfully withdrew $" << fixed << setprecision(2) << amount << endl;
            return true;
        }
    }

    void displayBalance() const {
        cout << "\n--- Account Details ---" << endl;
        cout << "Account Number: " << accountNumber << endl;
        cout << "Holder Name   : " << accountHolderName << endl;
        cout << "Current Balance: $" << fixed << setprecision(2) << balance << endl;
    }

    int getAccountNumber() const { return accountNumber; }
};

// --- Bank Class (Manager) ---
class Bank {
private:
    map<int, Account> accounts; // Stores accountNumber -> Account object
    int nextAccountNumber;

public:
    Bank() : nextAccountNumber(1001) {} // Start account numbers at 1001

    void createAccount() {
        string name;
        double initialDeposit;

        cout << "Enter Account Holder Name: ";
        cin.ignore(); // Clear buffer
        getline(cin, name);
        cout << "Enter Initial Deposit: ";
        cin >> initialDeposit;

        int accNum = nextAccountNumber++;
        Account newAcc(accNum, name, initialDeposit);
        accounts[accNum] = newAcc;

        cout << "\nAccount created successfully! Your Account Number is: " << accNum << endl;
    }

    Account* findAccount(int accNum) {
        if (accounts.find(accNum) != accounts.end()) {
            return &accounts[accNum];
        }
        return nullptr;
    }

    void depositMoney() {
        int accNum;
        double amount;
        cout << "Enter Account Number: ";
        cin >> accNum;

        Account* acc = findAccount(accNum);
        if (acc) {
            cout << "Enter amount to deposit: ";
            cin >> amount;
            acc->deposit(amount);
        } else {
            cout << "Error: Account not found!" << endl;
        }
    }

    void withdrawMoney() {
        int accNum;
        double amount;
        cout << "Enter Account Number: ";
        cin >> accNum;

        Account* acc = findAccount(accNum);
        if (acc) {
            cout << "Enter amount to withdraw: ";
            cin >> amount;
            acc->withdraw(amount);
        } else {
            cout << "Error: Account not found!" << endl;
        }
    }

    void checkBalance() {
        int accNum;
        cout << "Enter Account Number: ";
        cin >> accNum;

        Account* acc = findAccount(accNum);
        if (acc) {
            acc->displayBalance();
        } else {
            cout << "Error: Account not found!" << endl;
        }
    }
};

// --- Main Interface ---
int main() {
    Bank myBank;
    int choice;

    while (true) {
        cout << "\n============================";
        cout << "\n   WELCOME TO C++ BANK";
        cout << "\n============================";
        cout << "\n1. Create Account";
        cout << "\n2. Deposit Money";
        cout << "\n3. Withdraw Money";
        cout << "\n4. Check Balance";
        cout << "\n5. Exit";
        cout << "\nEnter choice: ";
        cin >> choice;

        switch (choice) {
            case 1: myBank.createAccount(); break;
            case 2: myBank.depositMoney(); break;
            case 3: myBank.withdrawMoney(); break;
            case 4: myBank.checkBalance(); break;
            case 5: cout << "Thank you for using our banking system!" << endl; return 0;
            default: cout << "Invalid choice! Please try again." << endl;
        }
    }

    return 0;
}
