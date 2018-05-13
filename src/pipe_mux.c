#include <stdlib.h>
#include <unistd.h>
#include <sys/select.h>
#include <fcntl.h>

/* currently a char is use to encode length
 * don't go over 255! */
#define BUFFER_SIZE 255

#define IN_PRFX 0
#define FIFO_PRFX 1

struct channel {
  int fileno;
  unsigned char prfx;
  int closed;
};

int main(int argc, char* argv[])
{
  if (argc != 2)
    return EXIT_FAILURE;

  struct channel channels[2];
  channels[0].fileno = STDIN_FILENO;
  channels[0].prfx = IN_PRFX;
  channels[0].closed = 0;
  channels[1].fileno = open(argv[1], O_RDONLY);
  channels[1].prfx = FIFO_PRFX;
  channels[1].closed = 0;
  
  fd_set fds;
  ssize_t read_cnt;
  unsigned char buf[BUFFER_SIZE];
  unsigned char len;
  for (;;) {
    FD_ZERO(&fds); /* Clear FD set for select */
    FD_SET(channels[0].fileno, &fds);
    FD_SET(channels[1].fileno, &fds);

    if (select(channels[1].fileno + 1, &fds, NULL, NULL, NULL)<0)
      break;

    for (int i=0; i<2; i++) {
      if (!channels[i].closed
          && FD_ISSET(channels[i].fileno, &fds)) {
        read_cnt = read(channels[i].fileno, buf, BUFFER_SIZE);
        if (read_cnt<1) {
          channels[i].closed = 1;
        }
        else {
          /* TODO handle incomplete writes using select */
          len = read_cnt;
          write(STDOUT_FILENO, &(channels[i].prfx), 1);
          write(STDOUT_FILENO, &len, 1);
          write(STDOUT_FILENO, buf, read_cnt);
        }
      }
    }

    if (channels[0].closed && channels[1].closed) {
      close(STDOUT_FILENO);
      exit(EXIT_SUCCESS);
    }
  }

  return EXIT_SUCCESS;
}
