#include "PsdPch.h"

#include "PsdStringUtil.h"
#include "PsdMemoryUtil.h"

#include <cwchar>
#include <cstdlib>
#include <cstring>
#include <clocale>


PSD_NAMESPACE_BEGIN

namespace stringUtil
{
	char *ConvertWString(const wchar_t* ws, Allocator* alloc)
	{
		if(ws == nullptr)
		{
			return nullptr;
		}
        std::setlocale(LC_ALL, "en_US.UTF-8");
        char *buffer;
		size_t n = std::wcslen(ws) * 4 + 1;
		buffer = static_cast<char*>(memoryUtil::AllocateArray<char>(alloc,n));
		std::memset(buffer,0,n);
		if(buffer == nullptr)
		{
			return nullptr;
		}
		std::wcstombs(buffer,ws,n);
		return buffer;
	}
}

PSD_NAMESPACE_END
