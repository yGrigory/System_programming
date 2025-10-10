#include <stdio.h>
#include <stdbool.h>

bool checkNonDecreasing(int n) {
    if (n < 10) {
        return true;
    }
    
    int prevDigit = n % 10; 
    n /= 10;
    
    while (n > 0) {
        int currentDigit = n % 10;
        if (currentDigit > prevDigit) {
            return false; 
        }
        prevDigit = currentDigit;
        n /= 10;
    }
    
    return true;
}

int main() {
    int number;
    
    printf("Введите число: ");
    scanf("%d", &number);
    
    bool result = checkNonDecreasing(number);
    
    if (result) {
        printf("Цифры в неубывающем порядке\n");
    } else {
        printf("Цифры НЕ в неубывающем порядке\n");
    }
    
    return 0;
}