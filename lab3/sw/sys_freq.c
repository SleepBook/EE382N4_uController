/*
 * Change system clock frequency
 *
 * Yuwei Liu
 */

#include <stdio.h>
#include <stdlib.h>

#define ARM_PLL_CTRL 0xF8000100
#define ARM_PLL_CFG  0xF8000110
#define PLL_STATUS 0xF800010C
#define ARM_CLK_CTRL 0xF8000120

#define ARM_PLL_CTRL_MASK 0x0007F000 // 18:12
#define ARM_PLL_CFG_MASK 0x003FFFF0 // 21:12 11:8 7:4
#define ARM_PLL_BYPASS_MASK 0x00000010 // 4
#define ARM_PLL_BYPASS_QUAL_MASK 0x00000008 // 3
#define ARM_PLL_RESET_MASK 0x00000001 // 0
#define PLL_STATUS_MASK 0x00000008 // 3
#define ARM_CLK_CTRL_MASK 0x00003F00 // 13:8

extern int pm(unsigned int target_addr, unsigned int value);
extern int dm(unsigned int target_addr, unsigned int *buffer);
extern unsigned int random10();

const unsigned int pll_div_p[8] = {
        40, 44, 20, 48, 2, 34, 1, 48
    };

const unsigned int clk_div_p[8] = {
        2, 2, 12, 3, 2, 20, 2, 2
    };

const unsigned int pll_cfg_val[67] = {
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0x002EE260, 0x002BC260, 0x0028A260,
    0x002712A0, 0x0023F2A0, 0x002262A0, 0x0020D2A0,
    0x001F42C0, 0x001DB2C0, 0x001C22C0, 0x001A92C0, 
    0x001902C0, 0x001902C0, 
    0x001772C0,
    0x0015E2C0, 0x0015E2C0,
    0x001452C0, 0x001452C0,
    0x0012C220, 0x0012C220, 0x0012C220,
    0x00113220, 0x00113220, 0x00113220, 
    0x000FA220, 0x000FA220, 0x000FA220, 0x000FA220, 
    0x000FA3C0, 0x000FA3C0, 0x000FA3C0, 0x000FA3C0, 0x000FA3C0, 0x000FA3C0, 0x000FA3C0,
    0x000FA240, 0x000FA240, 0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,0x000FA240,
    };

int main(int argc, char* argv[]){
    unsigned int index = 1;
    //index = (random10() % 8);
    if(1 < argc)
        index = atoi(argv[1]);
    if(8 < index)
        index = 8;
    else if(1 > index)
        index = 1;
    printf("The test number is: %d\n", index);

    // test: pll divider 40
    // 1. change ARM_PLL_CTRL[PLL_FDIV], ARM_PLL_CFG
    unsigned int pll_div;
    pll_div = pll_div_p[index - 1];
    printf("The PLL divider value is: %d\n", pll_div);
    unsigned int pll_ctrl, pll_cfg;

    dm(ARM_PLL_CTRL, &pll_ctrl);
    pll_ctrl = (pll_ctrl & (~ARM_PLL_CTRL_MASK)) | ((unsigned int)pll_div << 12);
    pm(ARM_PLL_CTRL, pll_ctrl);

    dm(ARM_PLL_CFG, &pll_cfg);
    pll_cfg = (pll_cfg & (~ARM_PLL_CFG_MASK)) | (pll_cfg_val[pll_div]);
    pm(ARM_PLL_CFG, pll_cfg);

    // 2. ARM_PLL_CTRL [PLL_BYPASS_FORCE<4>] -> 1
    dm(ARM_PLL_CTRL, &pll_ctrl);
    pll_ctrl = (pll_ctrl & (~ARM_PLL_BYPASS_MASK)) | ARM_PLL_BYPASS_MASK;
    pm(ARM_PLL_CTRL, pll_ctrl);

    // 2.1 ARM_PLL_CTRL [PLL_BYPASS_QUAL<3>] -> 0 // test
    dm(ARM_PLL_CTRL, &pll_ctrl);
    pll_ctrl = (pll_ctrl & (~ARM_PLL_BYPASS_QUAL_MASK)) & (~ARM_PLL_BYPASS_QUAL_MASK);
    pm(ARM_PLL_CTRL, pll_ctrl);

    // 3. ARM_PLL_CTRL [PLL_RESET] ->1 -> 0
    dm(ARM_PLL_CTRL, &pll_ctrl);
    pll_ctrl = (pll_ctrl & (~ARM_PLL_RESET_MASK)) | ARM_PLL_RESET_MASK;
    pm(ARM_PLL_CTRL, pll_ctrl);

    dm(ARM_PLL_CTRL, &pll_ctrl);
    pll_ctrl = (pll_ctrl & (~ARM_PLL_RESET_MASK)) & (~ARM_PLL_RESET_MASK);
    pm(ARM_PLL_CTRL, pll_ctrl);

    // 4. Read PLL_STATUS [3] to verify
    unsigned int pll_status;
    dm(PLL_STATUS, &pll_status);
    if((pll_status & PLL_STATUS_MASK) == 0)
        printf("ERROR: PLL is not locked and not in bypass\n");
    else printf("Successfully lock and bypass PLL\n");

    // 6. Change ARM_CLK_CTRL // test the new sequence
    unsigned int clk_div;
    unsigned int arm_clk_ctrl;
    clk_div = clk_div_p[index - 1];
    printf("The clock divider value is: %d\n", clk_div);

    dm(ARM_CLK_CTRL, &arm_clk_ctrl);
    arm_clk_ctrl = (arm_clk_ctrl & (~ARM_CLK_CTRL_MASK)) | ((unsigned int) clk_div << 8);
    pm(ARM_CLK_CTRL, arm_clk_ctrl);

    // 5. ARM_PLL_CTRL [PLL_BYPASS_FORCE<4>] -> 0
    dm(ARM_PLL_CTRL, &pll_ctrl);
    pll_ctrl = (pll_ctrl & (~ARM_PLL_BYPASS_MASK)) & (~ARM_PLL_BYPASS_MASK);
    pm(ARM_PLL_CTRL, pll_ctrl);

    return 0;
}
