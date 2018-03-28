#!/bin/bash

while true;
do
    freq=$(($RANDOM%8));
    #echo ${freq};
    case ${freq} in
        0)  #echo ${freq};
            sudo ./freq_test 1;
            sleep 60;
            ;;
        1)  #echo ${freq};
            sudo ./freq_test 2;
            sleep 65;
            ;;
        2)  #echo ${freq};
            sudo ./freq_test 3;
            sleep 18;
            ;;
        3)  #echo ${freq};
            sudo ./freq_test 4;
            sleep 50;
            ;;
        4)  #echo ${freq};
            sudo ./freq_test 5;
            sleep 14;
            ;;
        5)  #echo ${freq};
            sudo ./freq_test 6;
            sleep 19;
            ;;
        6)  #echo ${freq};
            sudo ./freq_test 7;
            sleep 12;
            ;;
        7)  #echo ${freq};
            sudo ./freq_test 8;
            sleep 70;
            ;;
    esac
done

