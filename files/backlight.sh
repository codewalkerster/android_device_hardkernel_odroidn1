#!/bin/sh

if [ -d "/sys/class/pwm/pwmchip1/pwm0" ]; then
    echo 0 > /sys/class/pwm/pwmchip1/unexport
else
    echo 0 > /sys/class/pwm/pwmchip1/export
    chmod 666 /sys/class/pwm/pwmchip1/pwm0/period
    chmod 666 /sys/class/pwm/pwmchip1/pwm0/enable
    chmod 666 /sys/class/pwm/pwmchip1/pwm0/duty_cycle
fi
