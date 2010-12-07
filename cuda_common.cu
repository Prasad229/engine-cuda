#include <cuda_common.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime_api.h>
#include <common.h>

#ifndef PAGEABLE
extern "C" void transferHostToDevice_PINNED (const unsigned char **input, uint32_t **deviceMem, uint8_t **hostMem, size_t *size) {
	cudaError_t cudaerrno;
	memcpy(*hostMem,*input,*size);
        _CUDA(cudaMemcpyAsync(*deviceMem, *hostMem, *size, cudaMemcpyHostToDevice, 0));
	}
#if CUDART_VERSION >= 2020
extern "C" void transferHostToDevice_ZEROCOPY (const unsigned char **input, uint32_t **deviceMem, uint8_t **hostMem, size_t *size) {
	//cudaError_t cudaerrno;
	memcpy(*hostMem,*input,*size);
	//_CUDA(cudaHostGetDevicePointer(&d_s,h_s, 0));
	}
#endif
#else
extern "C" void transferHostToDevice_PAGEABLE (const unsigned char **input, uint32_t **deviceMem, uint8_t **hostMem, size_t *size) {
	cudaError_t cudaerrno;
	_CUDA(cudaMemcpy(*deviceMem, *input, *size, cudaMemcpyHostToDevice));
	}
#endif
#ifndef PAGEABLE
extern "C" void transferDeviceToHost_PINNED   (unsigned char **output, uint32_t **deviceMem, uint8_t **hostMem, size_t *size) {
	cudaError_t cudaerrno;
        _CUDA(cudaMemcpyAsync(*hostMem, *deviceMem, *size, cudaMemcpyDeviceToHost, 0));
	_CUDA(cudaThreadSynchronize());
	memcpy(*output,*hostMem,*size);
	}
#if CUDART_VERSION >= 2020
extern "C" void transferDeviceToHost_ZEROCOPY (unsigned char **output, uint32_t **deviceMem, uint8_t **hostMem, size_t *size) {
	cudaError_t cudaerrno;
	_CUDA(cudaThreadSynchronize());
	memcpy(*output,*hostMem,*size);
	}
#endif
#else
extern "C" void transferDeviceToHost_PAGEABLE (unsigned char **output, uint32_t **deviceMem, uint8_t **hostMem, size_t *size) {
	cudaError_t cudaerrno;
	_CUDA(cudaMemcpy(*output,*deviceMem,*size, cudaMemcpyDeviceToHost));
	}
#endif

void checkCUDADevice(struct cudaDeviceProp *deviceProp, int output_verbosity) {
	int deviceCount;
	cudaError_t cudaerrno;

	_CUDA(cudaGetDeviceCount(&deviceCount));

	if (!deviceCount) {
		if (output_verbosity!=OUTPUT_QUIET) 
			fprintf(stderr,"There is no device supporting CUDA.\n");
		exit(EXIT_FAILURE);
	} else {
		if (output_verbosity>=OUTPUT_NORMAL) 
			fprintf(stdout,"Successfully found %d CUDA devices (CUDART_VERSION %d).\n",deviceCount, CUDART_VERSION);
	}
	_CUDA(cudaSetDevice(0));
	_CUDA(cudaGetDeviceProperties(deviceProp, 0));
	
	if (output_verbosity==OUTPUT_VERBOSE) {
        	fprintf(stdout,"\nDevice %d: \"%s\"\n", 0, deviceProp->name);
      	 	fprintf(stdout,"  CUDA Compute Capability:                       %d.%d\n", deviceProp->major,deviceProp->minor);
#if CUDART_VERSION >= 2000
        	fprintf(stdout,"  Number of multiprocessors (SM):                %d\n", deviceProp->multiProcessorCount);
#endif
#if CUDART_VERSION >= 2020
		fprintf(stdout,"  Integrated:                                    %s\n", deviceProp->integrated ? "Yes" : "No");
        	fprintf(stdout,"  Support host page-locked memory mapping:       %s\n", deviceProp->canMapHostMemory ? "Yes" : "No");
#endif
		fprintf(stdout,"\n");
		}
}

extern "C" void tobinary(unsigned char i) {
	unsigned char r=i%2;
	if(i>=2) { 
		tobinary(i/2);
	}
	putchar('0'+r); 
}

extern "C" const char *byte_to_binary(int x) {
	static char b[9];
	b[0] = '\0';

	int z;
	for (z = 256; z > 0; z >>= 1) {
		strcat(b, ((x & z) == z) ? "1" : "0");
	}

	return b;
}

// buffer must have length >= sizeof(int) + 1
// Write to the buffer backwards so that the binary representation
// is in the correct order i.e.  the LSB is on the far right
// instead of the far left of the printed string
extern "C" char *int2bin(unsigned int a, char *buffer, int buf_size) {
    buffer += (buf_size - 1);

    for (int i = 31; i >= 0; i--) {
        *buffer-- = (a & 1) + '0';

        a >>= 1;
    }

    return buffer;
}
