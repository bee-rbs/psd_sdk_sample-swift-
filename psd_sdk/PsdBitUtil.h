// Copyright 2011-2020, Molecular Matters GmbH <office@molecular-matters.com>
// See LICENSE.txt for licensing details (2-clause BSD License: https://opensource.org/licenses/BSD-2-Clause)

#pragma once

#include "Psdisunsigned.h"


PSD_NAMESPACE_BEGIN
/*
/// \ingroup Util
/// \namespace bitUtil
/// \brief Provides bit manipulation routines.
namespace bitUtil
{
	/// Returns whether a given number is a power-of-two.
	template <typename T>
	inline bool IsPowerOfTwo(T x);

	/// Rounds a number up to the next multiple of a power-of-two.
	template <typename T>
	inline T RoundUpToMultiple(T numToRound, T multipleOf);

	/// Rounds a number down to the next multiple of a power-of-two.
	template <typename T>
	inline T RoundDownToMultiple(T numToRound, T multipleOf);
}
*/

//#include "PsdBitUtil.inl"


namespace bitUtil
{
    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline bool IsPowerOfTwo(T x)
    {
        return (x & (x - 1)) == 0;
    }


    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline T RoundUpToMultiple(T numToRound, T multipleOf)
    {
        // make sure that this function is only called for unsigned types, and ensure that we want to round to a power-of-two
        static_assert(util::IsUnsigned<T>::value == true, "T must be an unsigned type.");
        PSD_ASSERT(IsPowerOfTwo(multipleOf), "Expected a power-of-two.");

        return (numToRound + (multipleOf - 1u)) & ~(multipleOf - 1u);
    }


    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline T RoundDownToMultiple(T numToRound, T multipleOf)
    {
        // make sure that this function is only called for unsigned types, and ensure that we want to round to a power-of-two
        static_assert(util::IsUnsigned<T>::value == true, "T must be an unsigned type.");
        PSD_ASSERT(IsPowerOfTwo(multipleOf), "Expected a power-of-two.");

        return numToRound & ~(multipleOf - 1u);
    }
}

PSD_NAMESPACE_END
