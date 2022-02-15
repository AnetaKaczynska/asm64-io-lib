// g++ -o example.o -c example.cpp && nasm -f elf64 -o lib.o lib.asm && g++ -o example lib.o example.o
#include <iostream>
using namespace std;


extern "C" char read_char();

extern "C" void print_char(char x);

extern "C" int read_int();

extern "C" void print_int(int x);

extern "C" char* read_string();

extern "C" void print_string(char* x);


int main(){
	cout<<"Please enter a character"<<endl;
	char c = read_char();
	read_char();   // read new line symbol
	print_char(c);
	cout<<endl;
	
	cout<<"Please enter an integer"<<endl;
	int i = read_int();
	print_int(i);
	cout<<endl;
	
	cout<<"Please enter a sentence"<<endl;
	char* s = read_string();
	print_string(s);
	cout<<endl;
	
	return 0;
}

