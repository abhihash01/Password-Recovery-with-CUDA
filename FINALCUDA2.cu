
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>

#include <stdlib.h>
#include <math.h>
#include <string.h>

__host__ __device__ void swap(char *x, char *y)
{
	char temp;
	temp = *x;
	*x = *y;
	*y = temp;
}

__device__ long hash(char *str)
{
	unsigned long hash = 5381;
	int c;

	while (c = *str++)
		hash = ((hash << 5) + hash) + c; 

	return hash;

}

__device__ void permute_device(char *a, int i, int n, int tid, int* count,char *d_b,int *d)
{
	if (i == n) {
		char* c = a - 1;
		//b[0] = c[0]; b[1] = c[1]; b[2] = c[2]; b[3] = c[3];
		//printf("Permutation no %i from thread no %i is equal to %s\n", count[0], tid, c); count[0] = count[0] + 1;
		long h1 = hash(c);
		long h2 = hash(d_b);

		if (h1 == h2)
		{
			printf("\nHashValue of found string=%d\n", h2);
			d[0] = 1;
			
			//return;
		}
		
	}
	else
	{
		for (int j = i; j <= n; j++)
		{
			swap((a + i), (a + j));
			permute_device(a, i + 1, n, tid, count,d_b,d);
			swap((a + i), (a + j));
		}
	}
}


__global__ void q4(char *a, char *b, int *C, int *d,int len)
{
	int id = threadIdx.x;
	int s = C[id];
	int c = C[id + 1];

	int count;
	
	char buf[20];
	int j = 0;
	for (int i = s + 1;i < c;i++) {
		buf[j++] = a[i];
	}
	
		long h1 = hash(buf);
		long h2 = hash(b);

		if (h1 == h2)
		{
			printf("\nHashValue of found string=%d\n", h2);
			d[0] = 1;
			//return;
		}


}

__global__ void permute_kernel(char* d_A, int size,char* d_B,int *d) {


	int tid = threadIdx.x;
	int count[1]; count[0] = 0;

	char local_array[10];

	for (int i = 0; i < size; i++) {
		local_array[i] = d_A[i];
	}
	if (threadIdx.x <= size-1) {
		swap(local_array + threadIdx.x, local_array);
		permute_device(local_array + 1, 0, size-1, tid, count,d_B,d);
	}

}

int main(int argc, char* argv[])
{
	clock_t start_t = clock();
	char h_b[30]="operco";
	int d = 0;
	FILE *fp;
	long lSize;
	char *buffer;

	fp = fopen("test.txt", "rb");
	if (!fp) perror("test.txt"), exit(1);

	fseek(fp, 0L, SEEK_END);
	lSize = ftell(fp);
	rewind(fp);

	/* allocate memory for entire content */
	buffer = (char*)calloc(1, lSize + 1);
	if (!buffer) fclose(fp), fputs("memory alloc fails", stderr), exit(1);

	/* copy the file into the buffer */
	if (1 != fread(buffer, lSize, 1, fp))
		fclose(fp), free(buffer), fputs("entire read fails", stderr), exit(1);

	/* do your work here, buffer is a string contains the whole text */
	//printf("%s", buffer);

	fclose(fp);

	
	//printf("Enter the password \n");
	//scanf("%s",h_b);
	int spaces[20000];
	int j = 0;
	spaces[j++] = -1;
	for (int i = 0;buffer[i] != '\0';i++) {
		
		if (buffer[i] == ' ')
			
			spaces[j++] = i;
	}
	printf("SPACES= %d %d %d %d", spaces[0],spaces[1],spaces[2],spaces[3]);
	//int k=strlen(spaces);
	int k = j;
	int n = strlen(buffer);
	int m = strlen(h_b);
	int dd[1];
	dd[0] = 0;






	// Device input vectors
	char *d_a;
	char *d_b;
	int *d_c;
	int *d_d;

	size_t bytes = n * sizeof(char);

	// Allocate memory for each vector on GPU
	cudaMalloc(&d_a, n * sizeof(char));
	cudaMalloc(&d_b, 30 * sizeof(char));
	cudaMalloc(&d_c, k * sizeof(int));
	cudaMalloc(&d_d, 1* sizeof(int));




	//int i;



	// Copy host vectors to device
	cudaMemcpy(d_a, buffer, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, m * sizeof(char), cudaMemcpyHostToDevice);
	cudaMemcpy(d_c, spaces, k * sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_d, dd, 1 * sizeof(int), cudaMemcpyHostToDevice);

	q4 << <1, j >> > (d_a, d_b, d_c, d_d,m);


	cudaMemcpy(dd, d_d, 1* sizeof(int), cudaMemcpyDeviceToHost);
	printf("\n");
	//int sum = 0;
	printf("Searching in the Dictionary \n");
		if (dd[0] == 1) {
			printf("Found %s in the Dictionary And Hash of password  has been calculated\n",h_b);
			//return 1;
		}
		else if (dd[0] == 0)
		{
			printf("Unable to find Password in Dictionary\n");
			printf("Finding Permutations of the words only if max length of string is 7\n");
			int t = 0;
			if(m<=7){
				for (int r = 0;r < k - 1;r++)
				{
					char buf[50];
					char* d_k;
					int s = spaces[r];
					int c = spaces[r + 1];
					//printf("m=%d\n", m);
					//printf("c-s-1=%d\n", c-s-1);

					if(m != (c - s - 1))
					{
						continue;
					}
					for (int i = s + 1;i < c;i++) {
						buf[t++] = buffer[i];
					}

					cudaMalloc((void**)&d_k, sizeof(buf));
					cudaMemcpy(d_k, buf, sizeof(buf), cudaMemcpyHostToDevice);

					permute_kernel << <1, t >> > (d_k, t, d_b, d_d);
					cudaMemcpy(dd, d_d, 1 * sizeof(int), cudaMemcpyDeviceToHost);
					if (dd[0] == 1) {
						printf("Found string '%s' while calculating permutation\n", h_b);
						//return 1;
						break;
					}
					memset(buf, 0, sizeof(buf));
					t = 0;

				}

			}
		}
		if (dd[0] == 0) {
			printf("Unable to find string even after computing permutation\n", h_b);
		}


		clock_t end_t = clock();
		clock_t total_t = (end_t - start_t);
		printf("Elapsed Time:%.3f seconds\n", (double)total_t / ((double)CLOCKS_PER_SEC));
	// Release device memory
	
		cudaFree(d_a);
		cudaFree(d_b);
		cudaFree(d_c);
		cudaFree(d_d);
		//cudaFree(d_k);


		//free(h_b);
	

	return 0;
}



