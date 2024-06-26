// Copyright 2011-2020, Molecular Matters GmbH <office@molecular-matters.com>
// See LICENSE.txt for licensing details (2-clause BSD License: https://opensource.org/licenses/BSD-2-Clause)

#pragma once

#include "PsdEndianConversion.h"
#include "PsdSyncFileReader.h"
#include "PsdSyncFileWriter.h"


PSD_NAMESPACE_BEGIN

/*
/// \ingroup Util
/// \namespace fileUtil
/// \brief Provides file reading utilities.
namespace fileUtil
{
	/// Reads built-in data types from a file.
	template <typename T>
	inline T ReadFromFile(SyncFileReader& reader);

	/// Reads built-in data types from a file, assuming they are stored as big-endian data.
	/// The read value is automatically converted to the native endianness.
	template <typename T>
	inline T ReadFromFileBE(SyncFileReader& reader);

	/// Writes built-in data types to a file.
	template <typename T>
	inline void WriteToFile(SyncFileWriter& writer, const T& data);

	/// Writes built-in data types to a file, assuming they are to be stored as big-endian data.
	/// The write value is automatically converted to the native endianness.
	template <typename T>
	inline void WriteToFileBE(SyncFileWriter& writer, const T& data);
}
*/
//#include "PsdSyncFileUtil.inl"

namespace fileUtil
{
    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline T ReadFromFile(SyncFileReader& reader)
    {
        T value = 0;
        reader.Read(&value, sizeof(T));
        return value;
    }


    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline T ReadFromFileBE(SyncFileReader& reader)
    {
        T value = ReadFromFile<T>(reader);
        value = endianUtil::BigEndianToNative(value);
        return value;
    }


    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline void WriteToFile(SyncFileWriter& writer, const T& data)
    {
        writer.Write(&data, sizeof(T));
    }


    // ---------------------------------------------------------------------------------------------------------------------
    // ---------------------------------------------------------------------------------------------------------------------
    template <typename T>
    inline void WriteToFileBE(SyncFileWriter& writer, const T& data)
    {
        const T dataBE = endianUtil::NativeToBigEndian(data);
        writer.Write(&dataBE, sizeof(T));
    }
}

PSD_NAMESPACE_END
