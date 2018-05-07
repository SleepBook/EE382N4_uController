#!/bin/bash

for addr in `seq -f "%9.0f" 0x43C01000 4 0x43C0108C`;
do
    pm $addr 0x00000000
done;

for addr in `seq -f "%9.0f" 0x00000000 0x100 0x000FFF00`;
do
    pm 0x43C00000 $((addr+17))
done

for addr in `seq -f "%9.0f" 0x43C03000 4 0x43C03018`;
do
    pm $addr 0x00000000
done;

for addr in `seq -f "%9.0f" 0x00000000 0x100 0x0003FF00`;
do
    pm 0x43C02000 $((addr+17))
done

