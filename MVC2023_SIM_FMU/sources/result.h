/* Internal header file for result generation. */

#ifndef result_h
#define result_h

#include "types.h"

/* For code export STORE_RESULT shall no be set */
#ifndef STORE_RESULT
/* empty for source code provided in FMUs */
#define result_setup(c) 0
#define result_teardown(c) 0
#define result_sample(c, f) 0
#define result_flush(c) 0
#else
/* ----------------- function delcarations ----------------- */

/* A non zero return value indicate memory error*/

/**
 * Setup. Calls result_sample once to get a sample point at start time.
 *
 * @param comp the FMI component
 */
int result_setup(Component* comp);

/**
 * Teardown. Calls result_sample to get a sample at stop time if necessary. Calls result_flush if necessary.
 *
 * @param comp the FMI component
 */
int result_teardown(Component* comp);

/**
 * Checks if the last sample time is not too close to the current and if not, sample the output.
 * For FMI 1.0, the sample is output on result file immediately.
 * For FMI >= 2.0, where time can be backed up due to possibility to set/get state, the sample is buffered
 * until result_flush is called or the maximum buffer size is exceeded during a call to result_sample.
 *
 * @param comp the FMI component
 * @param force whether the sample should be forced (set to fmiTrue for event, when duplicate samples at same time desired)
 */
int result_sample(Component* comp, FMIBoolean force);

/**
 * Output he values in the result buffer on file and resets the buffer.
 *
 * @param comp the FMI component
 */
int result_flush(Component* comp);

#endif /* STORE_RESULT */

#endif /* result_h */
