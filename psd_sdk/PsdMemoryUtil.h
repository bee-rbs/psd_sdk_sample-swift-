// Copyright 2011-2020, Molecular Matters GmbH <office@molecular-matters.com>
// See LICENSE.txt for licensing details (2-clause BSD License: https://opensource.org/licenses/BSD-2-Clause)

#pragma once

#include "PsdAllocator.h"
#include "Psdispod.h"
#include "PsdAssert.h"


PSD_NAMESPACE_BEGIN

/*
/// \ingroup Util
/// \namespace memoryUtil
/// \brief Provides memory allocation utilities.
namespace memoryUtil
{
	/// Allocates memory for an instance of type T, using T's default alignment.
	template <typename T>
	inline T* Allocate(Allocator* allocator);

	/// Allocates memory for \a count instances of type T, using T's default alignment.
	/// \remark Note that this does not call any constructors, and hence only works for POD types.
	template <typename T>
	inline T* AllocateArray(Allocator* allocator, size_t count);

	/// Frees memory previously allocated with \a allocator, and nullifies \a ptr.
	template <typename T>
	inline void Free(Allocator* allocator, T*& ptr);

	/// Frees an array previously allocated with \a allocator, and nullifies \a ptr.
	/// \remark Note that this does not call any destructors, and hence only works for POD types.
	template <typename T>
	inline void FreeArray(Allocator* allocator, T*& ptr);
}
*/
//#include "PsdMemoryUtil.inl"

namespace memoryUtil
{
    namespace detail
    {
        // ---------------------------------------------------------------------------------------------------------------------
        // ---------------------------------------------------------------------------------------------------------------------
        template <bool Value>
        struct BoolToType {};

        // ---------------------------------------------------------------------------------------------------------------------
        // ---------------------------------------------------------------------------------------------------------------------
        template <typename T>
        inline T* Allocate(Allocator* allocator, BoolToType<true>)
        {
            static_assert(util::IsPod<T>::value == true, "Type T must be a POD.");

            return static_cast<T*>(allocator->Allocate(sizeof(T), PSD_ALIGN_OF(T)));
        }

        // ---------------------------------------------------------------------------------------------------------------------
        // ---------------------------------------------------------------------------------------------------------------------
        template <typename T>
        inline T* Allocate(Allocator* allocator, BoolToType<false>)
        {
            static_assert(util::IsPod<T>::value == false, "Type T must not be a POD.");

            void* memory = allocator->Allocate(sizeof(T), PSD_ALIGN_OF(T));
            T* instance = new (memory) T;

            return instance;
        }

        // ---------------------------------------------------------------------------------------------------------------------
        // ---------------------------------------------------------------------------------------------------------------------
        template <typename T>
        inline void Free(Allocator* allocator, T*& ptr, BoolToType<true>)
        {
            static_assert(util::IsPod<T>::value == true, "Type T must be a POD.");

            allocator->Free(ptr);
        }

        // ---------------------------------------------------------------------------------------------------------------------
        // ---------------------------------------------------------------------------------------------------------------------
        template <typename T>
        inline void Free(Allocator* allocator, T*& ptr, BoolToType<false>)
        {
            static_assert(util::IsPod<T>::value == false, "Type T must not be a POD.");

            if (ptr)
            {
                ptr->~T();
            }

            allocator->Free(ptr);
        }
    }


    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline T* Allocate(Allocator* allocator)
    {
        PSD_ASSERT_NOT_NULL(allocator);

        // defer the allocation call to different functions, depending on whether T is a POD-type
        return detail::Allocate<T>(allocator, detail::BoolToType<util::IsPod<T>::value>());
    }


    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline T* AllocateArray(Allocator* allocator, size_t count)
    {
        PSD_ASSERT_NOT_NULL(allocator);
        static_assert(util::IsPod<T>::value == true, "Type T must be a POD.");

        return static_cast<T*>(allocator->Allocate(sizeof(T)*count, PSD_ALIGN_OF(T)));
    }


    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline void Free(Allocator* allocator, T*& ptr)
    {
        PSD_ASSERT_NOT_NULL(allocator);

        // defer the free call to different functions, depending on whether T is a POD-type
        detail::Free(allocator, ptr, detail::BoolToType<util::IsPod<T>::value>());
        ptr = nullptr;
    }


    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline void FreeArray(Allocator* allocator, T*& ptr)
    {
        PSD_ASSERT_NOT_NULL(allocator);

        allocator->Free(ptr);
        ptr = nullptr;
    }
}



PSD_NAMESPACE_END
