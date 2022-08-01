#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <wiringPi.h>

int halt = 0;
//state buffer (current state, previous state, state before that)
int state[3] = {-1,-1,-1};

void term(int signum)
{
   halt = 1;
}

void refresh(int signum)
{
   for (int i = 0; i < 3; i++) state[i] = -1;
}

int main(int argc, char *argv[]) {
    int pin = 0;
    int pull_mode = PUD_OFF;

    struct sigaction action;
    memset(&action, 0, sizeof(action));
    action.sa_handler = term;
    sigaction(SIGTERM, &action, NULL);

    struct sigaction action2;
    memset(&action, 0, sizeof(action2));
    action2.sa_handler = refresh;
    sigaction(SIGUSR1, &action2, NULL);
    sigaction(SIGUSR2, &action2, NULL);

    wiringPiSetupGpio(); //uses BCM numbering

    int opt;
    while ((opt = getopt(argc, argv, "p:udz")) != -1) {
        switch (opt) {
            case 'p':
                pin = atoi(optarg);
                break;
            case 'u':
                pull_mode = PUD_UP;
                break;
            case 'd':
                pull_mode = PUD_DOWN;
                break;
            case 'z':
                pull_mode = PUD_OFF; //default
                break;
            case '?':
                fprintf(stderr, "Unknown option: %c\n", optopt);
                return 1;
        }
    }

    if (pin == 0) {
        fprintf(stderr, "No pin number specified use -p with a BCM pin number\n");
        return 1;
    }

    pinMode(pin, INPUT);
    pullUpDnControl(pin, pull_mode);

    while (!halt) {
        state[0] = digitalRead(pin);
        if ((state[0] == state[1]) && (state[1] != state[2])) {
            printf("%d", state[0]);
        }
        for (int i = 2; i > 0; i--) state[i+1] = state[i];
        delay(60);
    }

    return 0;
}
