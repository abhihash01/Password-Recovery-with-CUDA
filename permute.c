#include <stdio.h>
#include <string.h>
    void main() {
        permute("ABC");
    }

    void permute(char str[]){
        char temp[20],a[20],buf[20],temp2[20];
        int i=0,j=0,k=0;
        strcpy(temp,str);
        // Step 1. Sort the string
       // Arrays.sort(temp);
        //System.out.println("String " + String.valueOf(temp));
        printf("String= %s",temp);
        int index = 0;
        int lowest = 0;
        while(1){
            // Step 2. Rightmost char smallest than its neighbour
            for( i = 0; i < strlen(temp) - 1; i++){
                if(temp[i] < temp[i+1]){
                    lowest = i;
                }
            }
            // index of CHAR1
            index = lowest;
            // Step3. Find the ceiling of the
            int l = findCeiling(temp, index);
            // Breaking condition at this juncture
            // all permutations are printed
            if(l == index) break;

            swap(temp, index, l);
            //String a = String.valueOf(temp);
            strcpy(a,temp);
            // Step4. Sort the substring
            char b[20];int p=0;
            for(k=index+1;k<strlen(a);k++)
            {
                b[p++]=a[k];
            }
            b[p]='\0';
            //printf("\nLL=%s\n",b);
            int n = strlen(b);
            //char[] b = a.substring(index + 1).toCharArray();
            for (i = 0; i < n-1; i++) {
      for (k = i+1; k < n; k++) {
         if (b[i] > b[k]) {
            char temp1 = b[i];
            b[i] = b[k];
            b[k] = temp1;
         }
      }
   }
   //printf("\nGG=%s\n",b);           // Arrays.sort(b);
            p=0;
           for(int k=0;k<index + 1;k++)
            {
                buf[p++]=a[k];
            }
            for(k=0;k<strlen(b);k++)
            {
               buf[p++]=b[k];
            }
            buf[p]='\0';
            //a = a.substring(0, index + 1) + String.valueOf(b);
            memset(temp,0,sizeof(buf));
            strcpy(temp,buf);
           // temp = a.toCharArray();
            //System.out.println( "String " + String.valueOf(temp));
                    printf("\nLALLU ABHILASH= %s\n",temp);

            //}
        }
    }

    /**
     *
     * @param temp
     * @param index
     * @return
     */
   int findCeiling(char temp[], int index){
        int k = index;
        char test = temp[index];
        while (k < strlen(temp) - 1){
            if(temp[index] < temp[k + 1]){
                index = k + 1;
                break;
            }
            k++;
        }
        k = index;
        while (k < strlen(temp) - 1){
            if((temp[index] > temp[k + 1]) && (temp[k + 1] > test)){
                index = k + 1;
            }
            k++;
        }
        return index;
    }


    void swap(char str[], int i, int j){
        char temp = str[i];
        str[i] = str[j];
        str[j] = temp;
    }

