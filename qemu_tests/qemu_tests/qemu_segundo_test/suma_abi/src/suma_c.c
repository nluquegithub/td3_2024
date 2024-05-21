

int suma_c (int ,int );

__attribute__((section(".text"))) int suma_c(int a, int b)
    {
        int c;

        c = a + b;

        return c;
    }