/*

  Silly little program to create a list of SAN LUN Serial Numbers
  suitable for using in a for loop.

  4 hex digits with a colon in the middle - XX:XX

  takes 2 args - the starting Serial Number and the ending Serial Number

*/

/*
#undef DEBUG
#define DEBUG
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>



int StringIndex(char *InputString, char Char);


int main ( int argc, char *argv[] )
{

  int Index1 = 0,
    Index2 = 0,
    Index3 = 0,
    Index4 = 0;

  char Digit1[17] = "0123456789ABCDEF",
    Digit2[17] = "0123456789ABCDEF",
    Digit3[17] = "0123456789ABCDEF",
    Digit4[17] = "0123456789ABCDEF";

  char SANID[6] = "--:--";

  if ( argc != 4 ) {
    printf("%s usage:  %s arrayDEC begin end\n", argv[0], argv[0]);
    exit(-1);
  }

  if ( argv[2][2] != ':' ) {
    printf("%s is not a valid SAN Serial Number.\n",argv[1]);
    exit(-1);
  }

  if ( argv[3][2] != ':' ) {
    printf("%s is not a valid SAN Serial Number.\n",argv[2]);
    exit(-1);
  }

#ifdef DEBUG
  printf("Initial Values:\n");
  printf("  %s\n", SANID);
  printf("  %c%c:%c%c\n", 
	 Digit4[Index4], Digit3[Index3], Digit2[Index2], Digit1[Index1]);
#endif

  /*  parse starting serial number and print it out  */

  Index4=StringIndex(Digit4,argv[2][0]);
  Index3=StringIndex(Digit3,argv[2][1]);
  Index2=StringIndex(Digit2,argv[2][3]);
  Index1=StringIndex(Digit1,argv[2][4]);

#ifdef DEBUG
  printf("parsed starting serial number:  %s = ", argv[2]);
  printf("%c%c:%c%c\n", 
	 Digit4[Index4], Digit3[Index3], Digit2[Index2], Digit1[Index1]);
  printf("%i\n", StringIndex(Digit3,'\0'));
#endif

  printf("%s %c%c:%c%c\n", argv[1],
	 Digit4[Index4], Digit3[Index3], Digit2[Index2], Digit1[Index1]);

  /*  loop to increment serial numbers and print them out */
  /*  stop when we have incremented to argv[2]  */

  SANID[0] = Digit4[Index4];
  SANID[1] = Digit3[Index3];
  SANID[3] = Digit2[Index2];
  SANID[4] = Digit1[Index1];

  while ( strcmp(SANID,argv[3]) != 0 ) {

#ifdef DEBUG
    printf("While Top:  %s %s\n",SANID,argv[3]);
    printf("%i\n",Index2);
#endif

    /*  increment the SANID  */

    if ( Index1 == 15 ) {
      Index2++;
      Index1=0;
    } else
      Index1++;


    if ( Index2 == 16 ) {
      Index3++;
      Index2=0;
    } 

    if ( Index3 == 16 ) {
      Index4++;
      Index3=0;
    } 

    if (Index4 == 16 ) {
      printf("THIS SHOULD NOT HAPPEN!!\n");
      exit(-2);
    }

    SANID[0] = Digit4[Index4];
    SANID[1] = Digit3[Index3];
    SANID[3] = Digit2[Index2];
    SANID[4] = Digit1[Index1];

    printf("%s %s\n",argv[1],SANID);


    /*    strcpy(SANID,argv[2]);*/

  }


}

int StringIndex(char *InputString, char Char)
{

  int i;

#ifdef DEBUG
  printf("StringIndex -->  ENTER\n");
  printf("StringIndex -->  %s\n",InputString);
  printf("StringIndex -->  %c\n",Char);
#endif

  for (i=0;i<=strlen(InputString);i++)
    if ( Char == InputString[i] )
      return(i);

  return(-1);
}
