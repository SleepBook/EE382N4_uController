#define LFSR10CR 0x43C00008
#define LFSR10DR 0x43C00000
#define LFSR32CR 0x43C01008
#define LFSR32DR 0x43C01000

extern int pm(unsigned int target_addr, unsigned int value);
extern int dm(unsigned int target_addr, unsigned int *buffer);

unsigned int random10()
{
    unsigned int val;

    pm(LFSR10CR, 0);
    pm(LFSR10CR, 1);
    dm(LFSR10DR, &val);

    return val;
}

unsigned int random32()
{
    unsigned int val;

    pm(LFSR32CR, 0);
    pm(LFSR32CR, 1);
    dm(LFSR32DR, &val);

    return val;
}

