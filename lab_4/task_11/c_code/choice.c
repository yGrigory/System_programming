#include <stdio.h>
#include <stdlib.h>

int main() {
    int n, vote;
    int yes_count = 0;
    
    printf("Введите количество судей: ");
    scanf("%d", &n);
    
    if (n <= 0) {
        printf("Количество судей должно быть положительным!\n");
        return 1;
    }
    
    // Сбор голосов от всех судей
    for (int i = 1; i <= n; i++) {
        printf("Судья %d. Введите голос (1-Да, 0-Нет): ", i);
        scanf("%d", &vote);
        
        if (vote == 1) {
            yes_count++;
        } else if (vote != 0) {
            printf("Ошибка! Голос должен быть 0 или 1.\n");
            i--; // Повторяем ввод для этого судьи
        }
    }
    
    // Принятие решения большинством голосов
    printf("\nРезультаты голосования:\n");
    printf("За: %d, Против: %d\n", yes_count, n - yes_count);
    
    if (yes_count > n / 2) {
        printf("Решение: ДА\n");
    } else {
        printf("Решение: НЕТ\n");
    }
    
    return 0;
}