/***
*
* Author: Peter Balan
*
* Writer.c should do the following:
*  Accept 2 arguments:
*  * first argument is a full file path, reffered as 'writefile'
*  * second argument is a text string which will be written to file, referred as 'writestr'
*
*  Exit code 1 if:
*  * it does not have 2 parameters ->> LOG_ERR level
*  * it cannot write the file ->> LOG_ERR level
*
*  Prints "Writing <writestr> to <writefile>" when write successfull->> LOG_DEBUG
*
*
***/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <syslog.h>

int main(int argc, char *argv[]) {
    // Open syslog for logging
    openlog("Assignment 2: Writer program", LOG_PID , LOG_USER);

    // Argument handling: Check for the two arguments needed
    if (argc != 3) {
        syslog(LOG_ERR, "Error: The script needs 2 parameters, but got %d.", argc - 1);
        fprintf(stderr, "Program usage: %s <writefile> <writestr>\n", argv[0]);
        closelog();
        exit(1);
    }

    // Extract arguments
    const char *writefile = argv[1];
    const char *writestr = argv[2];

    // Open the file for writing
    FILE *file = fopen(writefile, "w");
    if (file == NULL) {
        syslog(LOG_ERR, "Error: We cannot open file for writing. '%s': %s", writefile, strerror(errno));
        perror("Error: We cannot open file for writing.");
        closelog();
        exit(1);
    }

    // Write the string to the file
    if (fputs(writestr, file) == EOF) {
        syslog(LOG_ERR, "Failed to write to file '%s': %s", writefile, strerror(errno));
        perror("Error: We cannot write to file.");
        fclose(file);
        closelog();
        exit(1);
    }

    // Close the file
    if (fclose(file) != 0) {
        syslog(LOG_ERR, "Failed to close file '%s': %s", writefile, strerror(errno));
        perror("Error closing file");
        closelog();
        exit(1);
    }

    // Success message
    syslog(LOG_DEBUG, "Writing '%s' to '%s'", writestr, writefile);
    printf("Writing '%s' to '%s'\n", writestr, writefile);

    // Close syslog and exit
    closelog();
    return 0;
}
