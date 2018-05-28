#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>
#include <fcntl.h>

/* currently a char is use to encode length
 * don't go below 256! */
#define BUFFER_SIZE 256

#define IN_PRFX 0
#define FIFO_PRFX 1

ssize_t read_blocking(int filedes, unsigned char *buf, size_t len) {
  fd_set fds;
  ssize_t read_cnt, cnt;
  for (read_cnt=0, cnt=0; read_cnt<len; read_cnt += cnt) {
    FD_ZERO(&fds); // Clear FD set for select
    FD_SET(filedes, &fds);
    if (select(filedes + 1, &fds, NULL, NULL, NULL)<0)
      exit(EXIT_FAILURE);

    if (!FD_ISSET(filedes, &fds))
      continue;
    cnt = read(filedes, &buf[read_cnt], len-read_cnt);
    if (cnt < 1)
      exit(cnt);
  }

  if (read_cnt!=len)
    exit(EXIT_FAILURE);
  return read_cnt;
}

int main(int argc, char* argv[])
{
  unsigned char buf[BUFFER_SIZE];
  unsigned char len;
  unsigned char prfx;
  for (;;) {
    read_blocking(STDIN_FILENO, &prfx, 1);
    read_blocking(STDIN_FILENO, &len, 1);
    read_blocking(STDIN_FILENO, buf, len);

    switch (prfx) {
    case IN_PRFX:
      write(STDOUT_FILENO, buf, len);
      break;
    case FIFO_PRFX:
      write(STDERR_FILENO, buf, len);
      break;
    default:
      /* Corrupted stream */
      exit(EXIT_FAILURE);
    }
  }

  return EXIT_SUCCESS;
}
