////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
///                                                                              ///
///             AnyDVD trial reset .dll by JohnWho{TEAM RESURRECTiON}            /// 
///                                                                              ///
////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
#include "stdafx.h"
#include <windows.h>

int   myCount   = 0;
DWORD returnVal = 0;
DWORD origAddy  = 0;
DWORD stackHook = 0;

DWORD WINAPI ExitThread    ( LPVOID );
DWORD HookFunction(LPCSTR lpModule, LPCSTR lpFuncName, LPVOID lpFunction, unsigned char *lpBackup);
BOOL  UnHookFunction(LPCSTR lpModule, LPCSTR lpFuncName, unsigned char *lpBackup);
DWORD getFunction(LPCSTR lpModule, LPCSTR lpFuncName);

bool  myFunc();

BYTE  hook[5];



BOOL  WINAPI DllMain ( HINSTANCE hModule, DWORD dwReason, LPVOID lpvReserved )
{
    if (dwReason == DLL_PROCESS_ATTACH) HookFunction("kernel32.dll", "GetPrivateProfileStringA", myFunc, hook);
    
	return -1;
}



DWORD HookFunction(LPCSTR lpModule, LPCSTR lpFuncName, LPVOID lpFunction, unsigned char *lpBackup)
{
	DWORD dwAddr = (DWORD)GetProcAddress(GetModuleHandle(lpModule), lpFuncName);
	
	BYTE jmp[6] = { 0xe9,0x00, 0x00, 0x00, 0x00};

	ReadProcessMemory(GetCurrentProcess(), (LPVOID)dwAddr, lpBackup, 5, 0);

	DWORD dwCalc = ((DWORD)lpFunction - dwAddr - 5);

	memcpy(&jmp[1], &dwCalc, 4);

	WriteProcessMemory(GetCurrentProcess(), (LPVOID)dwAddr, jmp, 5, 0);

	return dwAddr;
}



DWORD getFunction(LPCSTR lpModule, LPCSTR lpFuncName)
{
	DWORD dwAddr = (DWORD)GetProcAddress(GetModuleHandle(lpModule), lpFuncName);
	
	return dwAddr;
}



BOOL UnHookFunction(LPCSTR lpModule, LPCSTR lpFuncName, unsigned char *lpBackup)
{
	DWORD dwAddr = (DWORD)GetProcAddress(GetModuleHandle(lpModule), lpFuncName);

	if (WriteProcessMemory(GetCurrentProcess(), (LPVOID)dwAddr, lpBackup, 5, 0))
		return TRUE;

	return FALSE;
}



BOOL iWrite ( DWORD Address, void* Data, DWORD Length )
{
	DWORD Old = 0;
	VirtualProtect( ( void* )( Address ), Length, PAGE_EXECUTE_READWRITE, &Old);
	memcpy( ( void* )Address, Data, Length );
    VirtualProtect( ( void* )( Address ), Length, Old, &Old);

    return 0;
}



bool __declspec( naked ) myStackHook()
{

   	_asm  {

		pushad
	}


    if (myCount < 1) {

	HookFunction("kernel32.dll", "GetPrivateProfileStringA", myFunc, hook);
	}


	CreateThread(NULL, NULL, ExitThread, NULL, NULL, NULL);
	

	_asm {

		popad
	}	
	

	_asm  {

        inc myCount
		cmp myCount,2
		jnz skip
		xor eax,eax
		add returnVal,0x21
skip:
		jmp returnVal
    }
}



bool __declspec( naked ) myFunc()
{

   	_asm {

		pushad
	}
	
	
	UnHookFunction("kernel32.dll", "GetPrivateProfileStringA", hook);
	origAddy = getFunction("kernel32.dll", "GetPrivateProfileStringA");
	stackHook = (DWORD)myStackHook;

    
	_asm  {

		popad
	}


   	_asm  {

		pushad
		mov     eax, esp
		mov     eax,[eax+0x20]
        mov     [returnVal],eax 
		mov     eax, [stackHook]
		mov     [esp+0x20],eax
		popad
		jmp origAddy
    }


}



DWORD WINAPI ExitThread(LPVOID)
{

   	_asm 
    {
doloop:
		cmp myCount,2
		jnz doloop
	}


    Sleep(50);

    ExitProcess(0);

	return 0;
}
