# Define compiler
CC=$(CROSS_COMPILE)gcc

default:
	@ $(CC) -o writer writer.c
	@ echo "Compiled writer with" $(CC)

clean:
	@ rm -f writer.o writer
	@ echo	"Removed writer file."
