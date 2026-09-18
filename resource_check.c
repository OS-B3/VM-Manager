#include <stdio.h>

int main() {
    double memory_usage;
    double load_ratio;

    if (scanf("%lf %lf", &memory_usage, &load_ratio) != 2) {
        printf("ERROR\n");
        return 1;
    }

    printf("Metric 1 (Memory): ");

    if (memory_usage >= 90) {
        printf("FAIL\n");
    } else if (memory_usage >= 75) {
        printf("WARN\n");
    } else {
        printf("PASS\n");
    }

    printf("Metric 2 (Load/Core): ");

    if (load_ratio > 2) {
        printf("FAIL\n");
    } else if (load_ratio > 1) {
        printf("WARN\n");
    } else {
        printf("PASS\n");
    }

    return 0;
}