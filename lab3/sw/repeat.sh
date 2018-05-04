#!/bin/bash

freq=0;
while true;
do
    echo ${freq};
    case ${freq} in
        0)  #echo ${freq};
            sudo ./freq_test 1;
            sleep $(($RANDOM%10+15));
            ;;
        1)  #echo ${freq};
            sudo ./freq_test 2;
            sleep $(($RANDOM%10+15));
            ;;
        2)  #echo ${freq};
            sudo ./freq_test 3;
            sleep $(($RANDOM%10+15));
            ;;
        3)  #echo ${freq};
            sudo ./freq_test 4;
            sleep $(($RANDOM%10+15));
            ;;
        4)  #echo ${freq};
            sudo ./freq_test 5;
            sleep $(($RANDOM%10+15));
            ;;
        5)  #echo ${freq};
            sudo ./freq_test 6;
            sleep $(($RANDOM%10+15));
            ;;
        6)  #echo ${freq};
            sudo ./freq_test 7;
            sleep $(($RANDOM%10+15));
            ;;
        7)  #echo ${freq};
            sudo ./freq_test 8;
            sleep $(($RANDOM%10+15));
            ;;
    esac
    freq=$(($((${freq}+1))%8));
done

