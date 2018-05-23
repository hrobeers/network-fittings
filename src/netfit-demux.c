#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>
#include <fcntl.h>

/* currently a char is use to encode length
 * don't go below 256! */
#define BUFFER_SIZE 256

#define IN_PRFX 0
#define FIFO_PRFX 1

int read_in(unsigned char *buf, size_t len) {
  fd_set fds;
  ssize_t read_cnt;
  unsigned char remain;
  for (read_cnt=0,remain=len; read_cnt<len; remain-=read_cnt) {
    FD_ZERO(&fds); // Clear FD set for select
    FD_SET(STDIN_FILENO, &fds);
    if (select(STDIN_FILENO + 1, &fds, NULL, NULL, NULL)<0)
      exit(-1);
    
    ssize_t cnt = read(STDIN_FILENO, &buf[read_cnt], remain);
    if (cnt < 1)
      exit(cnt);
    read_cnt += cnt;
  }
  return read_cnt == len;
}

int main(int argc, char* argv[])
{
  unsigned char buf[BUFFER_SIZE];
  unsigned char len;
  unsigned char prfx;
  for (;;) {
    read_in(&prfx, 1);
    read_in(&len, 1);
    read_in(buf, len);

    switch (prfx) {
    case IN_PRFX:
      write(STDOUT_FILENO, buf, len);
      break;
    case FIFO_PRFX:
      write(STDERR_FILENO, buf, len);
      break;
    }
  }

  return EXIT_SUCCESS;
}
