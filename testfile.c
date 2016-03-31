/* This is compiler design homework. */

/* To code,
   or not to code. */

// function declaration

int sub(int x, int y);
struct Student_Detail {
    int age;
    char *name;
    char *address;
};
int a;
int main(){

  // variables
  int a[][];
  int *b=&a;
  double c=10.6;
  char d='y';

  // statements
  a = 10/2;
  c = (b+3)*4-5;
  b = sub(10,8);

  return a;

}

// function
int sub(int x, int y){
  return x-y;
}
