// Third party dependencies
#include "/opt/homebrew/include/libssh2.h"

// Core POSIX networking 
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

// macOS terminal management & forks
#include <util.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <signal.h>