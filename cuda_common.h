#include <stdint.h>
#include <cuda_runtime_api.h>

static int __attribute__((unused)) output_verbosity;
static int __attribute__((unused)) isIntegrated;

#define _CUDA(call) {																	\
	call;				                                												\
	cudaerrno=cudaGetLastError();																	\
	if(cudaSuccess!=cudaerrno) {                                       					         						\
		if (output_verbosity!=OUTPUT_QUIET) fprintf(stderr, "Cuda error in file '%s' in line %i: %s.\n",__FILE__,__LINE__,cudaGetErrorString(cudaerrno));	\
		exit(EXIT_FAILURE);                                                  											\
    } }

#define _CUDA_N(msg) {                                    												\
	cudaerrno=cudaGetLastError();																	\
	if(cudaSuccess!=cudaerrno) {                                                											\
		if (output_verbosity!=OUTPUT_QUIET) fprintf(stderr, "Cuda error in file '%s' in line %i: %s.\n",__FILE__,__LINE__-3,cudaGetErrorString(cudaerrno));	\
		exit(EXIT_FAILURE);                                                  											\
    } }


#ifndef PAGEABLE
extern "C" void transferHostToDevice_PINNED (const unsigned char **input, uint32_t **deviceMem, uint8_t **hostMem, size_t *size);
extern "C" void transferDeviceToHost_PINNED (unsigned char **output, uint32_t **deviceMem, uint8_t **hostMem, size_t *size);
#if CUDART_VERSION >= 2020
extern "C" void transferHostToDevice_ZEROCOPY (const unsigned char **input, uint32_t **deviceMem, uint8_t **hostMem, size_t *size);
extern "C" void transferDeviceToHost_ZEROCOPY (unsigned char **output, uint32_t **deviceMem, uint8_t **hostMem, size_t *size);
#endif
#else
extern "C" void transferHostToDevice_PAGEABLE (const unsigned char **input, uint32_t **deviceMem, uint8_t **hostMem, size_t *size);
extern "C" void transferDeviceToHost_PAGEABLE (unsigned char **output, uint32_t **deviceMem, uint8_t **hostMem, size_t *size);
#endif

extern "C" void (*transferHostToDevice) (const unsigned char  **input, uint32_t **deviceMem, uint8_t **hostMem, size_t *size);
extern "C" void (*transferDeviceToHost) (      unsigned char **output, uint32_t **deviceMem, uint8_t **hostMem, size_t *size);

extern "C" void checkCUDADevice(struct cudaDeviceProp *deviceProp, int output_verbosity);

extern "C" void tobinary(unsigned char);
extern "C" const char *byte_to_binary(int);
extern "C" char *int2bin(unsigned int, char*, int);
