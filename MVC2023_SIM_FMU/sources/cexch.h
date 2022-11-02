#ifndef EXCEPTION_HANDLING
#define EXCEPTION_HANDLING

#if defined(__cplusplus)
extern "C" {
#endif

#include <setjmp.h>
#define MAX_EC 10
#define ERR_RECURSIVE -123456
extern jmp_buf exception_buffer[MAX_EC];
extern int exception_count;

#define EXCEPTION_TRY do { int exception_code = 0; if(exception_count == MAX_EC ) longjmp(exception_buffer[exception_count-1], ERR_RECURSIVE ); if ((exception_code = setjmp(exception_buffer[exception_count++])) == 0) {
#define EXCEPTION_THROW(code) if(exception_count)longjmp(exception_buffer[exception_count-1], code )
#define EXCEPTION_CATCH(code) } else if (code == exception_code) {
#define EXCEPTION_CATCH_ALL } else {
#define EXCEPTION_END } --exception_count;} while(0)

#if defined __cplusplus
}
#endif

#endif

