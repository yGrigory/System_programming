#include <stdio.h>
#include <stdlib.h>

int main() {
    int n;
    long long sum = 0;
    
    printf("Введите n: ");
    scanf("%d", &n);
    
    // Вычисление суммы ∑(-1)^k * k(k+4)(k+8)
    for (int k = 1; k <= n; k++) {
        int sign = (k % 2 == 0) ? 1 : -1;  // (-1)^k
        long long term = (long long)k * (k + 4) * (k + 8);
        sum += sign * term;
    }
    
    printf("Результат: %lld\n", sum);
    
    return 0;
}