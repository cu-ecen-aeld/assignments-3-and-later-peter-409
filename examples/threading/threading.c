#include "threading.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

// Optional: use these functions to add debug or error prints to your application
#define DEBUG_LOG(msg,...)
//#define DEBUG_LOG(msg,...) printf("threading: " msg "\n" , ##__VA_ARGS__)
#define ERROR_LOG(msg,...) printf("threading ERROR: " msg "\n" , ##__VA_ARGS__)

void* threadfunc(void* thread_param)
{

    // TODO: wait, obtain mutex, wait, release mutex as described by thread_data structure
    // hint: use a cast like the one below to obtain thread arguments from your parameter
    //struct thread_data* thread_func_args = (struct thread_data *) thread_param;

    // Define struct thread_data
    struct thread_data* thread_func_args = (struct thread_data *) thread_param;

    // Waiting
    usleep (1000*thread_func_args->wait_to_obtain_ms);

    // Obtaining mutex
    pthread_mutex_lock(thread_func_args->mutex);

    // Waiting again
    usleep (1000*thread_func_args->wait_to_release_ms);

    // Releasing mutex
    pthread_mutex_unlock(thread_func_args->mutex);

    // Setting thread_complete_success to true
    thread_func_args->thread_complete_success = true;

    return thread_param;
}


bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,int wait_to_obtain_ms, int wait_to_release_ms)
{
    /**
     * TODO: allocate memory for thread_data, setup mutex and wait arguments, pass thread_data to created thread
     * using threadfunc() as entry point.
     *
     * return true if successful.
     *
     * See implementation details in threading.h file comment block
     */

    // Allocating memory for thread_data
    struct thread_data* thread_params = malloc(sizeof(struct thread_data));

    // Setting up mutex and wait arguments
    thread_params->mutex = mutex;
    thread_params->wait_to_obtain_ms = wait_to_obtain_ms;
    thread_params->wait_to_release_ms = wait_to_release_ms;

    // Creating thread
    int thread_create_status = pthread_create(thread, NULL, threadfunc, thread_params);

    // If thread creation failed, return false, otherwise return true
    if (thread_create_status)
    {
        return false;
    }
    return true;
}
