#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>

int setup_serial() {
    int fd;
    fd = open("/dev/ttyUSB1", O_RDWR | O_NOCTTY | O_NDELAY);

    if (fd == -1) {
        perror("open_port: unable to open /dev/ttyUSB1 - ");
    } else {
        struct termio options;
        tcgetattr(fd, &options);

        cfsetispeed(&)
    }
}