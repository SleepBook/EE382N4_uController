#include <stdio.h>
#include <stdlib.h>
#define __USE_GNU
#include <sched.h>
#include <errno.h>
#include <unistd.h>
#include <pthread.h>
#include <sys/resource.h>

#define print_err_exit(err, msg) \
    do { errno = err; perror(msg); if(!lck_init_res) pthread_mutex_destroy(&lck); if(t_info) free(t_info); exit(EXIT_FAILURE); } while (0)

#define NUM_CPUS 2
#define MAIN_MAILBOX 1200

typedef struct thread_info_s
{
    pthread_t thread_id;  // ID returned by pthread_create()
    int core_id;  // Core ID we want this thread to set its affinity
    int dly;  // delay, the count of loops per execution of the application
    void (*app)(void *);  // function pointer pointing to the application
    void * arg;  // arguments for the application
    int * exe_cnt;  // main keeps counting how many times the app executed
    pthread_mutex_t * exe_cnt_lck;  // lock on exe_cnt
} thread_info_t;

thread_info_t * t_info = NULL;  // global to avoid memory leakage
pthread_mutex_t lck;
int lck_init_res = -1;  // hasn't initialized yet

// function to bind a thread to a specified cpu
void bind_thread2cpu(int pid, int cid)
{
    cpu_set_t cpuset;  // a bitset mask where on bit for one core
    int err;

    if(NUM_CPUS <= cid)
        print_err_exit(-1, "bind_thread2cpu()");
    CPU_ZERO(&cpuset);  // make an empty set
    CPU_SET(cid, &cpuset);  // add one cpu to set

    err = pthread_setaffinity_np(
            pid,
            sizeof(cpu_set_t),
            &cpuset
            );
    if(err)
        print_err_exit(err, "pthread_setaffinity_np()");
}

// thread template to repeat executing application with certain delay
void * thread_repeat_app(void * arg)
{
    thread_info_t * pt_info = arg;

    const pthread_t pid = pthread_self();
    const int cid = pt_info->core_id;
    void (* const papp)(void *) = pt_info->app;  // application pointer
    int cnt = 0;

    bind_thread2cpu(pid, cid);

    while(1)
    {
        if(0 == cnt % pt_info->dly)
        {
            papp(pt_info->arg);
            pthread_mutex_lock(pt_info->exe_cnt_lck);  // lock to inc
            *(pt_info->exe_cnt) += 1;  // increase execution count
            pthread_mutex_unlock(pt_info->exe_cnt_lck);  // release lock
        }
        ++cnt;
    }

    // should never return
    return 0;
}

// function to execute the memory test application
extern void mem_test(void * arg);
// function to execute the measure latency application
extern void measure_int(void * arg);
// function to use LFSR10 to generate a random value
extern unsigned int random10();
// function to use LFSR32 to generate a random value
extern unsigned int random32();

int main(int argc, char * argv[])
{
    int div = 5;  // control how long it takes to go next test
    if(1 < argc)  // test speed are set via command
        div = atoi(argv[1]);

    // Initialize exe_cnt and its lock
    int exe_cnt = 0;
    lck_init_res = pthread_mutex_init(&lck, NULL);
    if(lck_init_res)
        print_err_exit(lck_init_res, "pthread_mutex_init()");

    // Initialize thread creation attributes
    pthread_attr_t attr;
    const int attr_init_res = pthread_attr_init(&attr);
    if(attr_init_res)
        print_err_exit(attr_init_res, "pthread_attr_init()");

    // Set the stack size limit to 1 MB (0x100000 bytes)
    const int stack_size = 0x100000;
    const int set_stack_res = pthread_attr_setstacksize(&attr, stack_size);
    if(set_stack_res)
        print_err_exit(set_stack_res, "pthread_attr_setstacksize()");

    const int num_threads = 2;
    // Allocate memory for pthread_create() arguments
    t_info = calloc(num_threads, sizeof(thread_info_t));
    if(NULL == t_info)
        print_err_exit(-1, "calloc()");

    // Prepare thread information for memory test application in t_info[0]
    t_info[0].core_id = 0;  // run memoty test on CPU0
    t_info[0].dly = (random32() & 0xFFF) + 0x512;
    t_info[0].app = mem_test;
    t_info[0].arg = NULL;
    t_info[0].exe_cnt = &exe_cnt;
    t_info[0].exe_cnt_lck = &lck;
    const int mem_test_res = pthread_create(
            &t_info[0].thread_id,
            &attr,
            &thread_repeat_app,
            &t_info[0]
            );
    if(mem_test_res)
        print_err_exit(mem_test_res, "pthread_create(mem_test)");

    // Prepare thread information for measure int application in t_info[1]
    t_info[1].core_id = 1;  // run measure interrupt latency on CPU1
    t_info[1].dly = (random32() & 0xFFF) + 0x512;
    t_info[1].app = measure_int;
    t_info[1].arg = NULL;
    t_info[1].exe_cnt = &exe_cnt;
    t_info[1].exe_cnt_lck = &lck;
    const int measure_int_res = pthread_create(
            &t_info[1].thread_id,
            &attr,
            &thread_repeat_app,
            &t_info[1]
            );
    if(measure_int_res)
        print_err_exit(measure_int_res, "pthread_create(measure_int)");

    // Destroy the thread attributes object, since it is no longer needed
    const int destroy_res = pthread_attr_destroy(&attr);
    if(destroy_res)
        print_err_exit(destroy_res, "pthread_attr_destroy()");

    // Now join with each thread
    //const int join_mem_test = pthread_join(t_info[0].thread_id, NULL);
    //if(join_mem_test)
    //    print_err_exit(join_mem_test, "pthread_join(mem_test)");
    //const int join_measure_int = pthread_join(t_info[1].thread_id, NULL);
    //if(join_measure_int)
    //    print_err_exit(join_measure_int, "pthread_join(measure_int)");
    //printf("Threads are joined\n");

    setpriority(PRIO_PROCESS, getpid(), 19);  // be nice to children
    while(1)
    {
        static int cnt_curr;  // current exe_cnt divided by DIV
        static int cnt_old = 0;  // last query
        pthread_mutex_lock(&lck);  // lock to inc
        cnt_curr = exe_cnt / div;  // control the tests move on speed
        pthread_mutex_unlock(&lck);  // release lock
        if(cnt_curr != cnt_old)
        {
            switch(cnt_curr % 8)  // 8 tests
            {
                case 0:
                    printf("PLL divider=%d, clock divider=%d\n", 40, 2);
                    break;
                case 1:
                    printf("PLL divider=%d, clock divider=%d\n", 44, 2);
                    break;
                case 2:
                    printf("PLL divider=%d, clock divider=%d\n", 20, 12);
                    break;
                case 3:
                    printf("PLL divider=%d, clock divider=%d\n", 48, 3);
                    break;
                case 4:
                    printf("PLL divider=%d, clock divider=%d\n", 2, 2);
                    break;
                case 5:
                    printf("PLL divider=%d, clock divider=%d\n", 34, 20);
                    break;
                case 6:
                    printf("PLL divider=%d, clock divider=%d\n", 1, 2);
                    break;
                case 7:
                    printf("PLL divider=%d, clock divider=%d\n", 48, 2);
                    break;
                default:
                    printf("PLL divider=??, clock divider=??\n");
                    break;
            }
            cnt_old = cnt_curr;  // update
        }
        //system("sleep 5");
    }

    free(t_info);

    return 0;
}

