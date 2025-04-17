#ifndef	_P_GPIO_H
#define	_P_GPIO_H

#include "peripherals/base.h"

#define GPFSEL1         (PERIPHERAL_BASE+0x00200004)
#define GPSET0          (PERIPHERAL_BASE+0x0020001C)
#define GPCLR0          (PERIPHERAL_BASE+0x00200028)
#define GPPUD           (PERIPHERAL_BASE+0x00200094)
#define GPPUDCLK0       (PERIPHERAL_BASE+0x00200098)

#endif  /*_P_GPIO_H */