// ==========================================================
// FreeImage 3
//
// Design and implementation by
// - Floris van den Berg (flvdberg@wxs.nl)
// - Hervé Drolon (drolon@infonie.fr)
//
// Contributors:
// - see changes log named 'Whatsnew.txt', see header of each .h and .cpp file
//
// This file is part of FreeImage 3
//
// COVERED CODE IS PROVIDED UNDER THIS LICENSE ON AN "AS IS" BASIS, WITHOUT WARRANTY
// OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT LIMITATION, WARRANTIES
// THAT THE COVERED CODE IS FREE OF DEFECTS, MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE
// OR NON-INFRINGING. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE COVERED
// CODE IS WITH YOU. SHOULD ANY COVERED CODE PROVE DEFECTIVE IN ANY RESPECT, YOU (NOT
// THE INITIAL DEVELOPER OR ANY OTHER CONTRIBUTOR) ASSUME THE COST OF ANY NECESSARY
// SERVICING, REPAIR OR CORRECTION. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL
// PART OF THIS LICENSE. NO USE OF ANY COVERED CODE IS AUTHORIZED HEREUNDER EXCEPT UNDER
// THIS DISCLAIMER.
//
// Use at your own risk!
// ==========================================================
module deimos.freeimage;
extern(System):
// export: // doesn't yet work (Bugzilla 9816)
nothrow:
// Version information ------------------------------------------------------

enum FREEIMAGE_MAJOR_VERSION = 3;
enum FREEIMAGE_MINOR_VERSION = 16;
enum FREEIMAGE_RELEASE_SERIAL = 0;

// Compiler options ---------------------------------------------------------
template DLL_CALLCONV(T) if (is(typeof(*(T.init)) P == function)) {
	static if (is(typeof(*(T.init)) R == return)) {
            static if (is(typeof(*(T.init)) P == function)) {
                alias extern(System) R function(P) DLL_CALLCONV;
            }
	}
}
/++
#include <wchar.h>	// needed for UNICODE functions

#if defined(FREEIMAGE_LIB)
	#define DLL_API
	#define DLL_CALLCONV
#else
	#if defined(_WIN32) || defined(__WIN32__)
		#define DLL_CALLCONV __stdcall
		// The following ifdef block is the standard way of creating macros which make exporting
		// from a DLL simpler. All files within this DLL are compiled with the FREEIMAGE_EXPORTS
		// symbol defined on the command line. this symbol should not be defined on any project
		// that uses this DLL. This way any other project whose source files include this file see
		// DLL_API functions as being imported from a DLL, wheras this DLL sees symbols
		// defined with this macro as being exported.
		#ifdef FREEIMAGE_EXPORTS
			#define DLL_API __declspec(dllexport)
		#else
			#define DLL_API __declspec(dllimport)
		#endif // FREEIMAGE_EXPORTS
	#else
		// try the gcc visibility support (see http://gcc.gnu.org/wiki/Visibility)
		#if defined(__GNUC__) && ((__GNUC__ >= 4) || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4))
			#ifndef GCC_HASCLASSVISIBILITY
				#define GCC_HASCLASSVISIBILITY
			#endif
		#endif // __GNUC__
		#define DLL_CALLCONV
		#if defined(GCC_HASCLASSVISIBILITY)
			#define DLL_API __attribute__ ((visibility("default")))
		#else
			#define DLL_API
		#endif
	#endif // WIN32 / !WIN32
#endif // FREEIMAGE_LIB
++/
// Some versions of gcc may have BYTE_ORDER or __BYTE_ORDER defined
// If your big endian system isn't being detected, add an OS specific check
version (LittleEndian) {}
else version = FREEIMAGE_BIGENDIAN;
// #endif // BYTE_ORDER

// This really only affects 24 and 32 bit formats, the rest are always RGB order.
enum FREEIMAGE_COLORORDER_BGR = 0;
enum FREEIMAGE_COLORORDER_RGB = 1;
version (FREEIMAGE_BIGENDIAN)
    alias FREEIMAGE_COLORORDER = FREEIMAGE_COLORORDER_RGB;
else
    alias FREEIMAGE_COLORORDER = FREEIMAGE_COLORORDER_BGR;

// Ensure 4-byte enums if we're using Borland C++ compilers
/++
#if defined(__BORLANDC__)
#pragma option push -b
#endif
++/

// For C compatibility --------------------------------------------------------
/++
#ifdef __cplusplus
#define FI_DEFAULT(x)	= x
#define FI_ENUM(x)      enum x
#define FI_STRUCT(x)	struct x
#else
#define FI_DEFAULT(x)
#define FI_ENUM(x)      typedef int x; enum x
#define FI_STRUCT(x)	typedef struct x x; struct x
#endif
++/

// Bitmap types -------------------------------------------------------------
struct FIBITMAP { void *data; }
struct FIMULTIBITMAP { void *data; }

// Types used in the library (directly copied from Windows) -----------------
/++
#if defined(__MINGW32__) && defined(_WINDOWS_H)
#define _WINDOWS_	// prevent a bug in MinGW32
#endif // __MINGW32__

#ifndef _WINDOWS_
#define _WINDOWS_
++/

enum FALSE = 0;
enum TRUE = 0;
enum NULL = null;

enum SEEK_SET = 0;
enum SEEK_CUR = 1;
enum SEEK_END = 2;

alias BOOL = int;
alias BYTE = ubyte;
alias WORD = ushort;
alias DWORD = uint;
alias LONG = int;
alias INT64 = long;
alias UINT64 = ulong;

/++
#if (defined(_WIN32) || defined(__WIN32__))
#pragma pack(push, 1)
#else
#pragma pack(1)
#endif // WIN32
++/

struct RGBQUAD {
static if (FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR) {
  BYTE rgbBlue;
  BYTE rgbGreen;
  BYTE rgbRed;
} else {
  BYTE rgbRed;
  BYTE rgbGreen;
  BYTE rgbBlue;
} // FREEIMAGE_COLORORDER
  BYTE rgbReserved;
}

struct RGBTRIPLE {
static if (FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR) {
  BYTE rgbBlue;
  BYTE rgbGreen;
  BYTE rgbRed;
} else {
  BYTE rgbRed;
  BYTE rgbGreen;
  BYTE rgbBlue;
} // FREEIMAGE_COLORORDER
}

/++
#if (defined(_WIN32) || defined(__WIN32__))
#pragma pack(pop)
#else
#pragma pack()
#endif // WIN32
++/

struct BITMAPINFOHEADER{
  DWORD biSize;
  LONG  biWidth;
  LONG  biHeight;
  WORD  biPlanes;
  WORD  biBitCount;
  DWORD biCompression;
  DWORD biSizeImage;
  LONG  biXPelsPerMeter;
  LONG  biYPelsPerMeter;
  DWORD biClrUsed;
  DWORD biClrImportant;
}
alias PBITMAPINFOHEADER = BITMAPINFOHEADER*;

struct BITMAPINFO {
  BITMAPINFOHEADER bmiHeader;
  RGBQUAD[1]       bmiColors;
}
alias PBITMAPINFO = BITMAPINFO*;

// #endif // _WINDOWS_

// Types used in the library (specific to FreeImage) ------------------------

/++
#if (defined(_WIN32) || defined(__WIN32__))
#pragma pack(push, 1)
#else
#pragma pack(1)
#endif // WIN32
++/

/** 48-bit RGB
*/
struct FIRGB16 {
	WORD red;
	WORD green;
	WORD blue;
}

/** 64-bit RGBA
*/
struct FIRGBA16 {
	WORD red;
	WORD green;
	WORD blue;
	WORD alpha;
}

/** 96-bit RGB Float
*/
struct FIRGBF {
	float red;
	float green;
	float blue;
}

/** 128-bit RGBA Float
*/
struct FIRGBAF {
	float red;
	float green;
	float blue;
	float alpha;
}

/** Data structure for COMPLEX type (complex number)
*/
struct FICOMPLEX {
    /// real part
	double r;
	/// imaginary part
    double i;
}

/++
#if (defined(_WIN32) || defined(__WIN32__))
#pragma pack(pop)
#else
#pragma pack()
#endif // WIN32
++/

// Indexes for byte arrays, masks and shifts for treating pixels as words ---
// These coincide with the order of RGBQUAD and RGBTRIPLE -------------------

version (FREEIMAGE_BIGENDIAN) {
static if (FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR) {
// Little Endian (x86 / MS Windows, Linux) : BGR(A) order
enum FI_RGBA_RED				 = 2;
enum FI_RGBA_GREEN			 = 1;
enum FI_RGBA_BLUE			 = 0;
enum FI_RGBA_ALPHA			 = 3;
enum FI_RGBA_RED_MASK		 = 0x00FF0000;
enum FI_RGBA_GREEN_MASK		 = 0x0000FF00;
enum FI_RGBA_BLUE_MASK		 = 0x000000FF;
enum FI_RGBA_ALPHA_MASK		 = 0xFF000000;
enum FI_RGBA_RED_SHIFT		 = 16;
enum FI_RGBA_GREEN_SHIFT		 = 8;
enum FI_RGBA_BLUE_SHIFT		 = 0;
enum FI_RGBA_ALPHA_SHIFT		 = 24;
} else {
// Little Endian (x86 / MaxOSX) : RGB(A) order
enum FI_RGBA_RED				 = 0;
enum FI_RGBA_GREEN			 = 1;
enum FI_RGBA_BLUE			 = 2;
enum FI_RGBA_ALPHA			 = 3;
enum FI_RGBA_RED_MASK		 = 0x000000FF;
enum FI_RGBA_GREEN_MASK		 = 0x0000FF00;
enum FI_RGBA_BLUE_MASK		 = 0x00FF0000;
enum FI_RGBA_ALPHA_MASK		 = 0xFF000000;
enum FI_RGBA_RED_SHIFT		 = 0;
enum FI_RGBA_GREEN_SHIFT		 = 8;
enum FI_RGBA_BLUE_SHIFT		 = 16;
enum FI_RGBA_ALPHA_SHIFT		 = 24;
} // FREEIMAGE_COLORORDER
} else {
static if (FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR) {
// Big Endian (PPC / none) : BGR(A) order
enum FI_RGBA_RED				 = 2;
enum FI_RGBA_GREEN			 = 1;
enum FI_RGBA_BLUE			 = 0;
enum FI_RGBA_ALPHA			 = 3;
enum FI_RGBA_RED_MASK		 = 0x0000FF00;
enum FI_RGBA_GREEN_MASK		 = 0x00FF0000;
enum FI_RGBA_BLUE_MASK		 = 0xFF000000;
enum FI_RGBA_ALPHA_MASK		 = 0x000000FF;
enum FI_RGBA_RED_SHIFT		 = 8;
enum FI_RGBA_GREEN_SHIFT		 = 16;
enum FI_RGBA_BLUE_SHIFT		 = 24;
enum FI_RGBA_ALPHA_SHIFT		 = 0;
} else {
// Big Endian (PPC / Linux, MaxOSX) : RGB(A) order
enum FI_RGBA_RED				 = 0;
enum FI_RGBA_GREEN			 = 1;
enum FI_RGBA_BLUE			 = 2;
enum FI_RGBA_ALPHA			 = 3;
enum FI_RGBA_RED_MASK		 = 0xFF000000;
enum FI_RGBA_GREEN_MASK		 = 0x00FF0000;
enum FI_RGBA_BLUE_MASK		 = 0x0000FF00;
enum FI_RGBA_ALPHA_MASK		 = 0x000000FF;
enum FI_RGBA_RED_SHIFT		 = 24;
enum FI_RGBA_GREEN_SHIFT		 = 16;
enum FI_RGBA_BLUE_SHIFT		 = 8;
enum FI_RGBA_ALPHA_SHIFT		 = 0;
} // FREEIMAGE_COLORORDER
} // FREEIMAGE_BIGENDIAN

enum FI_RGBA_RGB_MASK		 = (FI_RGBA_RED_MASK|FI_RGBA_GREEN_MASK|FI_RGBA_BLUE_MASK);

// The 16bit macros only include masks and shifts, since each color element is not byte aligned

enum FI16_555_RED_MASK		 = 0x7C00;
enum FI16_555_GREEN_MASK		 = 0x03E0;
enum FI16_555_BLUE_MASK		 = 0x001F;
enum FI16_555_RED_SHIFT		 = 10;
enum FI16_555_GREEN_SHIFT	 = 5;
enum FI16_555_BLUE_SHIFT		 = 0;
enum FI16_565_RED_MASK		 = 0xF800;
enum FI16_565_GREEN_MASK		 = 0x07E0;
enum FI16_565_BLUE_MASK		 = 0x001F;
enum FI16_565_RED_SHIFT		 = 11;
enum FI16_565_GREEN_SHIFT	 = 5;
enum FI16_565_BLUE_SHIFT		 = 0;

// ICC profile support ------------------------------------------------------

enum FIICC_DEFAULT			 = 0x00;
enum FIICC_COLOR_IS_CMYK		 = 0x01;

struct FIICCPROFILE {
	WORD    flags;	// info flag
	DWORD	size;	// profile's size measured in bytes
	void   *data;	// points to a block of contiguous memory containing the profile
}

// Important enums ----------------------------------------------------------

/** I/O image format identifiers.
*/
alias FREE_IMAGE_FORMAT = int;
enum : FREE_IMAGE_FORMAT {
	FIF_UNKNOWN = -1,
	FIF_BMP		= 0,
	FIF_ICO		= 1,
	FIF_JPEG	= 2,
	FIF_JNG		= 3,
	FIF_KOALA	= 4,
	FIF_LBM		= 5,
	FIF_IFF = FIF_LBM,
	FIF_MNG		= 6,
	FIF_PBM		= 7,
	FIF_PBMRAW	= 8,
	FIF_PCD		= 9,
	FIF_PCX		= 10,
	FIF_PGM		= 11,
	FIF_PGMRAW	= 12,
	FIF_PNG		= 13,
	FIF_PPM		= 14,
	FIF_PPMRAW	= 15,
	FIF_RAS		= 16,
	FIF_TARGA	= 17,
	FIF_TIFF	= 18,
	FIF_WBMP	= 19,
	FIF_PSD		= 20,
	FIF_CUT		= 21,
	FIF_XBM		= 22,
	FIF_XPM		= 23,
	FIF_DDS		= 24,
	FIF_GIF     = 25,
	FIF_HDR		= 26,
	FIF_FAXG3	= 27,
	FIF_SGI		= 28,
	FIF_EXR		= 29,
	FIF_J2K		= 30,
	FIF_JP2		= 31,
	FIF_PFM		= 32,
	FIF_PICT	= 33,
	FIF_RAW		= 34,
	FIF_WEBP	= 35,
	FIF_JXR		= 36
}

/** Image type used in FreeImage.
*/
alias FREE_IMAGE_TYPE = int;
enum : FREE_IMAGE_TYPE {
	FIT_UNKNOWN = 0,	// unknown type
	FIT_BITMAP  = 1,	// standard image			: 1-, 4-, 8-, 16-, 24-, 32-bit
	FIT_UINT16	= 2,	// array of unsigned short	: unsigned 16-bit
	FIT_INT16	= 3,	// array of short			: signed 16-bit
	FIT_UINT32	= 4,	// array of unsigned long	: unsigned 32-bit
	FIT_INT32	= 5,	// array of long			: signed 32-bit
	FIT_FLOAT	= 6,	// array of float			: 32-bit IEEE floating point
	FIT_DOUBLE	= 7,	// array of double			: 64-bit IEEE floating point
	FIT_COMPLEX	= 8,	// array of FICOMPLEX		: 2 x 64-bit IEEE floating point
	FIT_RGB16	= 9,	// 48-bit RGB image			: 3 x 16-bit
	FIT_RGBA16	= 10,	// 64-bit RGBA image		: 4 x 16-bit
	FIT_RGBF	= 11,	// 96-bit RGB float image	: 3 x 32-bit IEEE floating point
	FIT_RGBAF	= 12	// 128-bit RGBA float image	: 4 x 32-bit IEEE floating point
}

/** Image color type used in FreeImage.
*/
alias FREE_IMAGE_COLOR_TYPE = int;
enum : FREE_IMAGE_COLOR_TYPE {
	FIC_MINISWHITE = 0,		// min value is white
    FIC_MINISBLACK = 1,		// min value is black
    FIC_RGB        = 2,		// RGB color model
    FIC_PALETTE    = 3,		// color map indexed
	FIC_RGBALPHA   = 4,		// RGB color model with alpha channel
	FIC_CMYK       = 5		// CMYK color model
}

/** Color quantization algorithms.
Constants used in FreeImage_ColorQuantize.
*/
alias FREE_IMAGE_QUANTIZE = int;
enum : FREE_IMAGE_QUANTIZE {
    FIQ_WUQUANT = 0,		// Xiaolin Wu color quantization algorithm
    FIQ_NNQUANT = 1			// NeuQuant neural-net quantization algorithm by Anthony Dekker
}

/** Dithering algorithms.
Constants used in FreeImage_Dither.
*/
alias FREE_IMAGE_DITHER = int;
enum : FREE_IMAGE_DITHER {
    FID_FS			= 0,	// Floyd & Steinberg error diffusion
	FID_BAYER4x4	= 1,	// Bayer ordered dispersed dot dithering (order 2 dithering matrix)
	FID_BAYER8x8	= 2,	// Bayer ordered dispersed dot dithering (order 3 dithering matrix)
	FID_CLUSTER6x6	= 3,	// Ordered clustered dot dithering (order 3 - 6x6 matrix)
	FID_CLUSTER8x8	= 4,	// Ordered clustered dot dithering (order 4 - 8x8 matrix)
	FID_CLUSTER16x16= 5,	// Ordered clustered dot dithering (order 8 - 16x16 matrix)
	FID_BAYER16x16	= 6		// Bayer ordered dispersed dot dithering (order 4 dithering matrix)
}

/** Lossless JPEG transformations
Constants used in FreeImage_JPEGTransform
*/
alias FREE_IMAGE_JPEG_OPERATION = int;
enum : FREE_IMAGE_JPEG_OPERATION {
	FIJPEG_OP_NONE			= 0,	// no transformation
	FIJPEG_OP_FLIP_H		= 1,	// horizontal flip
	FIJPEG_OP_FLIP_V		= 2,	// vertical flip
	FIJPEG_OP_TRANSPOSE		= 3,	// transpose across UL-to-LR axis
	FIJPEG_OP_TRANSVERSE	= 4,	// transpose across UR-to-LL axis
	FIJPEG_OP_ROTATE_90		= 5,	// 90-degree clockwise rotation
	FIJPEG_OP_ROTATE_180	= 6,	// 180-degree rotation
	FIJPEG_OP_ROTATE_270	= 7		// 270-degree clockwise (or 90 ccw)
}

/** Tone mapping operators.
Constants used in FreeImage_ToneMapping.
*/
alias FREE_IMAGE_TMO = int;
enum : FREE_IMAGE_TMO {
    FITMO_DRAGO03	 = 0,	// Adaptive logarithmic mapping (F. Drago, 2003)
	FITMO_REINHARD05 = 1,	// Dynamic range reduction inspired by photoreceptor physiology (E. Reinhard, 2005)
	FITMO_FATTAL02	 = 2	// Gradient domain high dynamic range compression (R. Fattal, 2002)
}

/** Upsampling / downsampling filters.
Constants used in FreeImage_Rescale.
*/
alias FREE_IMAGE_FILTER = int;
enum : FREE_IMAGE_FILTER {
	FILTER_BOX		  = 0,	// Box, pulse, Fourier window, 1st order (constant) b-spline
	FILTER_BICUBIC	  = 1,	// Mitchell & Netravali's two-param cubic filter
	FILTER_BILINEAR   = 2,	// Bilinear filter
	FILTER_BSPLINE	  = 3,	// 4th order (cubic) b-spline
	FILTER_CATMULLROM = 4,	// Catmull-Rom spline, Overhauser spline
	FILTER_LANCZOS3	  = 5	// Lanczos3 filter
};

/** Color channels.
Constants used in color manipulation routines.
*/
alias FREE_IMAGE_COLOR_CHANNEL = int;
enum : FREE_IMAGE_COLOR_CHANNEL {
	FICC_RGB	= 0,	// Use red, green and blue channels
	FICC_RED	= 1,	// Use red channel
	FICC_GREEN	= 2,	// Use green channel
	FICC_BLUE	= 3,	// Use blue channel
	FICC_ALPHA	= 4,	// Use alpha channel
	FICC_BLACK	= 5,	// Use black channel
	FICC_REAL	= 6,	// Complex images: use real part
	FICC_IMAG	= 7,	// Complex images: use imaginary part
	FICC_MAG	= 8,	// Complex images: use magnitude
	FICC_PHASE	= 9		// Complex images: use phase
};

// Metadata support ---------------------------------------------------------

/**
  Tag data type information (based on TIFF specifications)

  Note: RATIONALs are the ratio of two 32-bit integer values.
*/
alias FREE_IMAGE_MDTYPE = int;
enum : FREE_IMAGE_MDTYPE {
	FIDT_NOTYPE		= 0,	// placeholder
	FIDT_BYTE		= 1,	// 8-bit unsigned integer
	FIDT_ASCII		= 2,	// 8-bit bytes w/ last byte null
	FIDT_SHORT		= 3,	// 16-bit unsigned integer
	FIDT_LONG		= 4,	// 32-bit unsigned integer
	FIDT_RATIONAL	= 5,	// 64-bit unsigned fraction
	FIDT_SBYTE		= 6,	// 8-bit signed integer
	FIDT_UNDEFINED	= 7,	// 8-bit untyped data
	FIDT_SSHORT		= 8,	// 16-bit signed integer
	FIDT_SLONG		= 9,	// 32-bit signed integer
	FIDT_SRATIONAL	= 10,	// 64-bit signed fraction
	FIDT_FLOAT		= 11,	// 32-bit IEEE floating point
	FIDT_DOUBLE		= 12,	// 64-bit IEEE floating point
	FIDT_IFD		= 13,	// 32-bit unsigned integer (offset)
	FIDT_PALETTE	= 14,	// 32-bit RGBQUAD
	FIDT_LONG8		= 16,	// 64-bit unsigned integer
	FIDT_SLONG8		= 17,	// 64-bit signed integer
	FIDT_IFD8		= 18	// 64-bit unsigned integer (offset)
};

/**
  Metadata models supported by FreeImage
*/
alias FREE_IMAGE_MDMODEL = int;
enum : FREE_IMAGE_MDMODEL {
	FIMD_NODATA			= -1,
	FIMD_COMMENTS		= 0,	// single comment or keywords
	FIMD_EXIF_MAIN		= 1,	// Exif-TIFF metadata
	FIMD_EXIF_EXIF		= 2,	// Exif-specific metadata
	FIMD_EXIF_GPS		= 3,	// Exif GPS metadata
	FIMD_EXIF_MAKERNOTE = 4,	// Exif maker note metadata
	FIMD_EXIF_INTEROP	= 5,	// Exif interoperability metadata
	FIMD_IPTC			= 6,	// IPTC/NAA metadata
	FIMD_XMP			= 7,	// Abobe XMP metadata
	FIMD_GEOTIFF		= 8,	// GeoTIFF metadata
	FIMD_ANIMATION		= 9,	// Animation metadata
	FIMD_CUSTOM			= 10,	// Used to attach other metadata types to a dib
	FIMD_EXIF_RAW		= 11	// Exif metadata as a raw buffer
};

/**
  Handle to a metadata model
*/
struct FIMETADATA { void *data; }

/**
  Handle to a FreeImage tag
*/
struct FITAG { void *data; }

// File IO routines ---------------------------------------------------------

// #ifndef FREEIMAGE_IO
// #define FREEIMAGE_IO

alias fi_handle = void*;
alias FI_ReadProc = DLL_CALLCONV!(uint function(void *buffer, uint size, uint count, fi_handle handle));
alias FI_WriteProc = DLL_CALLCONV!(uint function(void *buffer, uint size, uint count, fi_handle handle));
alias FI_SeekProc = DLL_CALLCONV!(int function(fi_handle handle, long offset, int origin));
alias FI_TellProc = DLL_CALLCONV!(long function(fi_handle handle));

/++
#if (defined(_WIN32) || defined(__WIN32__))
#pragma pack(push, 1)
#else
#pragma pack(1)
#endif // WIN32
++/

struct FreeImageIO {
	FI_ReadProc  read_proc;     // pointer to the function used to read data
    FI_WriteProc write_proc;    // pointer to the function used to write data
    FI_SeekProc  seek_proc;     // pointer to the function used to seek
    FI_TellProc  tell_proc;     // pointer to the function used to aquire the current position
}

/++
#if (defined(_WIN32) || defined(__WIN32__))
#pragma pack(pop)
#else
#pragma pack()
#endif // WIN32
++/

/**
Handle to a memory I/O stream
*/
struct FIMEMORY { void *data; };

// #endif // FREEIMAGE_IO

// Plugin routines ----------------------------------------------------------

// #ifndef PLUGINS
// #define PLUGINS

alias FI_FormatProc = DLL_CALLCONV!(const(char)* function());
alias FI_DescriptionProc = DLL_CALLCONV!(const(char)* function());
alias FI_ExtensionListProc = DLL_CALLCONV!(const(char)* function());
alias FI_RegExprProc = DLL_CALLCONV!(const(char)* function());
alias FI_OpenProc = DLL_CALLCONV!(void* function(FreeImageIO *io, fi_handle handle, BOOL read));
alias FI_CloseProc = DLL_CALLCONV!(void function(FreeImageIO *io, fi_handle handle, void *data));
alias FI_PageCountProc = DLL_CALLCONV!(int function(FreeImageIO *io, fi_handle handle, void *data));
alias FI_PageCapabilityProc = DLL_CALLCONV!(int function(FreeImageIO *io, fi_handle handle, void *data));
alias FI_LoadProc = DLL_CALLCONV!(FIBITMAP *function(FreeImageIO *io, fi_handle handle, int page, int flags, void *data));
alias FI_SaveProc = DLL_CALLCONV!(BOOL function(FreeImageIO *io, FIBITMAP *dib, fi_handle handle, int page, int flags, void *data));
alias FI_ValidateProc = DLL_CALLCONV!(BOOL function(FreeImageIO *io, fi_handle handle));
alias FI_MimeProc = DLL_CALLCONV!(const(char)* function());
alias FI_SupportsExportBPPProc = DLL_CALLCONV!(BOOL function(int bpp));
alias FI_SupportsExportTypeProc = DLL_CALLCONV!(BOOL function(FREE_IMAGE_TYPE type));
alias FI_SupportsICCProfilesProc = DLL_CALLCONV!(BOOL function());
alias FI_SupportsNoPixelsProc = DLL_CALLCONV!(BOOL function());

struct Plugin {
	FI_FormatProc format_proc;
	FI_DescriptionProc description_proc;
	FI_ExtensionListProc extension_proc;
	FI_RegExprProc regexpr_proc;
	FI_OpenProc open_proc;
	FI_CloseProc close_proc;
	FI_PageCountProc pagecount_proc;
	FI_PageCapabilityProc pagecapability_proc;
	FI_LoadProc load_proc;
	FI_SaveProc save_proc;
	FI_ValidateProc validate_proc;
	FI_MimeProc mime_proc;
	FI_SupportsExportBPPProc supports_export_bpp_proc;
	FI_SupportsExportTypeProc supports_export_type_proc;
	FI_SupportsICCProfilesProc supports_icc_profiles_proc;
	FI_SupportsNoPixelsProc supports_no_pixels_proc;
}

alias FI_InitProc = DLL_CALLCONV!(void function(Plugin *plugin, int format_id));

// #endif // PLUGINS


// Load / Save flag constants -----------------------------------------------

enum FIF_LOAD_NOPIXELS  = 0x8000;	//! loading: load the image header only (not supported by all plugins, default to full loading)

enum BMP_DEFAULT          = 0;
enum BMP_SAVE_RLE         = 1;
enum CUT_DEFAULT          = 0;
enum DDS_DEFAULT			 = 0;
enum EXR_DEFAULT			 = 0;		//! save data as half with piz-based wavelet compression
enum EXR_FLOAT			 = 0x0001;	//! save data as float instead of as half (not recommended)
enum EXR_NONE			 = 0x0002;	//! save with no compression
enum EXR_ZIP				 = 0x0004;	//! save with zlib compression, in blocks of 16 scan lines
enum EXR_PIZ				 = 0x0008;	//! save with piz-based wavelet compression
enum EXR_PXR24			 = 0x0010;	//! save with lossy 24-bit float compression
enum EXR_B44				 = 0x0020;	//! save with lossy 44% float compression - goes to 22% when combined with EXR_LC
enum EXR_LC				 = 0x0040;	//! save images with one luminance and two chroma channels, rather than as RGB (lossy compression)
enum FAXG3_DEFAULT		 = 0;
enum GIF_DEFAULT			 = 0;
enum GIF_LOAD256			 = 1;		//! load the image as a 256 color image with ununsed palette entries, if it's 16 or 2 color
enum GIF_PLAYBACK		 = 2;		//! 'Play' the GIF to generate each frame (as 32bpp) instead of returning raw frame data when loading
enum HDR_DEFAULT			 = 0;
enum ICO_DEFAULT          = 0;
enum ICO_MAKEALPHA		 = 1;		//! convert to 32bpp and create an alpha channel from the AND-mask when loading
enum IFF_DEFAULT          = 0;
enum J2K_DEFAULT			 = 0;		//! save with a 16:1 rate
enum JP2_DEFAULT			 = 0;		//! save with a 16:1 rate
enum JPEG_DEFAULT         = 0;		//! loading (see JPEG_FAST); saving (see JPEG_QUALITYGOOD|JPEG_SUBSAMPLING_420)
enum JPEG_FAST            = 0x0001;	//! load the file as fast as possible, sacrificing some quality
enum JPEG_ACCURATE        = 0x0002;	//! load the file with the best quality, sacrificing some speed
enum JPEG_CMYK			 = 0x0004;	//! load separated CMYK "as is" (use | to combine with other load flags)
enum JPEG_EXIFROTATE		 = 0x0008;	//! load and rotate according to Exif 'Orientation' tag if available
enum JPEG_GREYSCALE		 = 0x0010;	//! load and convert to a 8-bit greyscale image
enum JPEG_QUALITYSUPERB   = 0x80;	//! save with superb quality (100:1)
enum JPEG_QUALITYGOOD     = 0x0100;	//! save with good quality (75:1)
enum JPEG_QUALITYNORMAL   = 0x0200;	//! save with normal quality (50:1)
enum JPEG_QUALITYAVERAGE  = 0x0400;	//! save with average quality (25:1)
enum JPEG_QUALITYBAD      = 0x0800;	//! save with bad quality (10:1)
enum JPEG_PROGRESSIVE	 = 0x2000;	//! save as a progressive-JPEG (use | to combine with other save flags)
enum JPEG_SUBSAMPLING_411  = 0x1000;		//! save with high 4x1 chroma subsampling (4:1:1)
enum JPEG_SUBSAMPLING_420  = 0x4000;		//! save with medium 2x2 medium chroma subsampling (4:2:0) - default value
enum JPEG_SUBSAMPLING_422  = 0x8000;		//! save with low 2x1 chroma subsampling (4:2:2)
enum JPEG_SUBSAMPLING_444  = 0x10000;	//! save with no chroma subsampling (4:4:4)
enum JPEG_OPTIMIZE		 = 0x20000;		//! on saving, compute optimal Huffman coding tables (can reduce a few percent of file size)
enum JPEG_BASELINE		 = 0x40000;		//! save basic JPEG, without metadata or any markers
enum KOALA_DEFAULT        = 0;
enum LBM_DEFAULT          = 0;
enum MNG_DEFAULT          = 0;
enum PCD_DEFAULT          = 0;
enum PCD_BASE             = 1;		//! load the bitmap sized 768 x 512
enum PCD_BASEDIV4         = 2;		//! load the bitmap sized 384 x 256
enum PCD_BASEDIV16        = 3;		//! load the bitmap sized 192 x 128
enum PCX_DEFAULT          = 0;
enum PFM_DEFAULT          = 0;
enum PICT_DEFAULT         = 0;
enum PNG_DEFAULT          = 0;
enum PNG_IGNOREGAMMA		 = 1;		//! loading: avoid gamma correction
enum PNG_Z_BEST_SPEED			 = 0x0001;	//! save using ZLib level 1 compression flag (default value is 6)
enum PNG_Z_DEFAULT_COMPRESSION	 = 0x0006;	//! save using ZLib level 6 compression flag (default recommended value)
enum PNG_Z_BEST_COMPRESSION		 = 0x0009;	//! save using ZLib level 9 compression flag (default value is 6)
enum PNG_Z_NO_COMPRESSION		 = 0x0100;	//! save without ZLib compression
enum PNG_INTERLACED				 = 0x0200;	//! save using Adam7 interlacing (use | to combine with other save flags)
enum PNM_DEFAULT          = 0;
enum PNM_SAVE_RAW         = 0;       //! if set the writer saves in RAW format (i.e. P4, P5 or P6)
enum PNM_SAVE_ASCII       = 1;       //! if set the writer saves in ASCII format (i.e. P1, P2 or P3)
enum PSD_DEFAULT          = 0;
enum PSD_CMYK			 = 1;		//! reads tags for separated CMYK (default is conversion to RGB)
enum PSD_LAB				 = 2;		//! reads tags for CIELab (default is conversion to RGB)
enum RAS_DEFAULT          = 0;
enum RAW_DEFAULT          = 0;		//! load the file as linear RGB 48-bit
enum RAW_PREVIEW			 = 1;		//! try to load the embedded JPEG preview with included Exif Data or default to RGB 24-bit
enum RAW_DISPLAY			 = 2;		//! load the file as RGB 24-bit
enum RAW_HALFSIZE		 = 4;		//! output a half-size color image
enum SGI_DEFAULT			 = 0;
enum TARGA_DEFAULT        = 0;
enum TARGA_LOAD_RGB888    = 1;       //! if set the loader converts RGB555 and ARGB8888 -> RGB888.
enum TARGA_SAVE_RLE		 = 2;		//! if set, the writer saves with RLE compression
enum TIFF_DEFAULT         = 0;
enum TIFF_CMYK			 = 0x0001;	//! reads/stores tags for separated CMYK (use | to combine with compression flags)
enum TIFF_PACKBITS        = 0x0100;  //! save using PACKBITS compression
enum TIFF_DEFLATE         = 0x0200;  //! save using DEFLATE compression (a.k.a. ZLIB compression)
enum TIFF_ADOBE_DEFLATE   = 0x0400;  //! save using ADOBE DEFLATE compression
enum TIFF_NONE            = 0x0800;  //! save without any compression
enum TIFF_CCITTFAX3		 = 0x1000;  //! save using CCITT Group 3 fax encoding
enum TIFF_CCITTFAX4		 = 0x2000;  //! save using CCITT Group 4 fax encoding
enum TIFF_LZW			 = 0x4000;	//! save using LZW compression
enum TIFF_JPEG			 = 0x8000;	//! save using JPEG compression
enum TIFF_LOGLUV			 = 0x10000;	//! save using LogLuv compression
enum WBMP_DEFAULT         = 0;
enum XBM_DEFAULT			 = 0;
enum XPM_DEFAULT			 = 0;
enum WEBP_DEFAULT		 = 0;		//! save with good quality (75:1)
enum WEBP_LOSSLESS		 = 0x100;	//! save in lossless mode
enum JXR_DEFAULT			 = 0;		//! save with quality 80 and no chroma subsampling (4:4:4)
enum JXR_LOSSLESS		 = 0x0064;	//! save lossless
enum JXR_PROGRESSIVE		 = 0x2000;	//! save as a progressive-JXR (use | to combine with other save flags)

// Background filling options ---------------------------------------------------------
// Constants used in FreeImage_FillBackground and FreeImage_EnlargeCanvas

enum FI_COLOR_IS_RGB_COLOR			 = 0x00;	// RGBQUAD color is a RGB color (contains no valid alpha channel)
enum FI_COLOR_IS_RGBA_COLOR			 = 0x01;	// RGBQUAD color is a RGBA color (contains a valid alpha channel)
enum FI_COLOR_FIND_EQUAL_COLOR		 = 0x02;	// For palettized images: lookup equal RGB color from palette
enum FI_COLOR_ALPHA_IS_INDEX			 = 0x04;	// The color's rgbReserved member (alpha) contains the palette index to be used
enum FI_COLOR_PALETTE_SEARCH_MASK	 = (FI_COLOR_FIND_EQUAL_COLOR | FI_COLOR_ALPHA_IS_INDEX);	// No color lookup is performed


//#ifdef __cplusplus
//extern "C" {
//#endif

// Init / Error routines ----------------------------------------------------

void  FreeImage_Initialise(BOOL load_local_plugins_only = FALSE);
void  FreeImage_DeInitialise();

// Version routines ---------------------------------------------------------

const(char)* FreeImage_GetVersion();
const(char)* FreeImage_GetCopyrightMessage();

// Message output functions -------------------------------------------------

alias FreeImage_OutputMessageFunction = void  function(FREE_IMAGE_FORMAT fif, const(char)* msg);
alias FreeImage_OutputMessageFunctionStdCall = DLL_CALLCONV!(void function(FREE_IMAGE_FORMAT fif, const(char)* msg));

void  FreeImage_SetOutputMessageStdCall(FreeImage_OutputMessageFunctionStdCall omf);
void  FreeImage_SetOutputMessage(FreeImage_OutputMessageFunction omf);
void  FreeImage_OutputMessageProc(int fif, const(char)* fmt, ...);

// Allocate / Clone / Unload routines ---------------------------------------

FIBITMAP * FreeImage_Allocate(int width, int height, int bpp, uint red_mask = 0, uint green_mask = 0, uint blue_mask = 0);
FIBITMAP * FreeImage_AllocateT(FREE_IMAGE_TYPE type, int width, int height, int bpp = 8, uint red_mask = 0, uint green_mask = 0, uint blue_mask = 0);
FIBITMAP *  FreeImage_Clone(FIBITMAP *dib);
void  FreeImage_Unload(FIBITMAP *dib);

// Header loading routines
BOOL  FreeImage_HasPixels(FIBITMAP *dib);

// Load / Save routines -----------------------------------------------------

FIBITMAP * FreeImage_Load(FREE_IMAGE_FORMAT fif, const(char)* filename, int flags = 0);
FIBITMAP * FreeImage_LoadU(FREE_IMAGE_FORMAT fif, const(wchar)* filename, int flags = 0);
FIBITMAP * FreeImage_LoadFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags = 0);
BOOL  FreeImage_Save(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const(char)* filename, int flags = 0);
BOOL  FreeImage_SaveU(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const(wchar)* filename, int flags = 0);
BOOL  FreeImage_SaveToHandle(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FreeImageIO *io, fi_handle handle, int flags = 0);

// Memory I/O stream routines -----------------------------------------------

FIMEMORY * FreeImage_OpenMemory(BYTE *data = null, DWORD size_in_bytes = 0);
void  FreeImage_CloseMemory(FIMEMORY *stream);
FIBITMAP * FreeImage_LoadFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags = 0);
BOOL  FreeImage_SaveToMemory(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FIMEMORY *stream, int flags = 0);
long  FreeImage_TellMemory(FIMEMORY *stream);
BOOL  FreeImage_SeekMemory(FIMEMORY *stream, long offset, int origin);
BOOL  FreeImage_AcquireMemory(FIMEMORY *stream, BYTE **data, DWORD *size_in_bytes);
uint  FreeImage_ReadMemory(void *buffer, uint size, uint count, FIMEMORY *stream);
uint  FreeImage_WriteMemory(const(void)* buffer, uint size, uint count, FIMEMORY *stream);

FIMULTIBITMAP * FreeImage_LoadMultiBitmapFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags = 0);
BOOL  FreeImage_SaveMultiBitmapToMemory(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FIMEMORY *stream, int flags);

// Plugin Interface ---------------------------------------------------------

FREE_IMAGE_FORMAT  FreeImage_RegisterLocalPlugin(FI_InitProc proc_address, const(char)* format = null, const(char)* description = null, const(char)* extension = null, const(char)* regexpr = null);
FREE_IMAGE_FORMAT  FreeImage_RegisterExternalPlugin(const(char)* path, const(char)* format = null, const(char)* description = null, const(char)* extension = null, const(char)* regexpr = null);
int  FreeImage_GetFIFCount();
int  FreeImage_SetPluginEnabled(FREE_IMAGE_FORMAT fif, BOOL enable);
int  FreeImage_IsPluginEnabled(FREE_IMAGE_FORMAT fif);
FREE_IMAGE_FORMAT  FreeImage_GetFIFFromFormat(const(char)* format);
FREE_IMAGE_FORMAT  FreeImage_GetFIFFromMime(const(char)* mime);
const(char)*  FreeImage_GetFormatFromFIF(FREE_IMAGE_FORMAT fif);
const(char)*  FreeImage_GetFIFExtensionList(FREE_IMAGE_FORMAT fif);
const(char)*  FreeImage_GetFIFDescription(FREE_IMAGE_FORMAT fif);
const(char)*  FreeImage_GetFIFRegExpr(FREE_IMAGE_FORMAT fif);
const(char)*  FreeImage_GetFIFMimeType(FREE_IMAGE_FORMAT fif);
FREE_IMAGE_FORMAT  FreeImage_GetFIFFromFilename(const(char)* filename);
FREE_IMAGE_FORMAT  FreeImage_GetFIFFromFilenameU(const(wchar)* filename);
BOOL  FreeImage_FIFSupportsReading(FREE_IMAGE_FORMAT fif);
BOOL  FreeImage_FIFSupportsWriting(FREE_IMAGE_FORMAT fif);
BOOL  FreeImage_FIFSupportsExportBPP(FREE_IMAGE_FORMAT fif, int bpp);
BOOL  FreeImage_FIFSupportsExportType(FREE_IMAGE_FORMAT fif, FREE_IMAGE_TYPE type);
BOOL  FreeImage_FIFSupportsICCProfiles(FREE_IMAGE_FORMAT fif);
BOOL  FreeImage_FIFSupportsNoPixels(FREE_IMAGE_FORMAT fif);

// Multipaging interface ----------------------------------------------------

FIMULTIBITMAP *  FreeImage_OpenMultiBitmap(FREE_IMAGE_FORMAT fif, const(char)* filename, BOOL create_new, BOOL read_only, BOOL keep_cache_in_memory = FALSE, int flags = 0);
FIMULTIBITMAP *  FreeImage_OpenMultiBitmapFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags = 0);
BOOL  FreeImage_SaveMultiBitmapToHandle(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FreeImageIO *io, fi_handle handle, int flags = 0);
BOOL  FreeImage_CloseMultiBitmap(FIMULTIBITMAP *bitmap, int flags = 0);
int  FreeImage_GetPageCount(FIMULTIBITMAP *bitmap);
void  FreeImage_AppendPage(FIMULTIBITMAP *bitmap, FIBITMAP *data);
void  FreeImage_InsertPage(FIMULTIBITMAP *bitmap, int page, FIBITMAP *data);
void  FreeImage_DeletePage(FIMULTIBITMAP *bitmap, int page);
FIBITMAP *  FreeImage_LockPage(FIMULTIBITMAP *bitmap, int page);
void  FreeImage_UnlockPage(FIMULTIBITMAP *bitmap, FIBITMAP *data, BOOL changed);
BOOL  FreeImage_MovePage(FIMULTIBITMAP *bitmap, int target, int source);
BOOL  FreeImage_GetLockedPageNumbers(FIMULTIBITMAP *bitmap, int *pages, int *count);

// Filetype request routines ------------------------------------------------

FREE_IMAGE_FORMAT  FreeImage_GetFileType(const(char)* filename, int size = 0);
FREE_IMAGE_FORMAT  FreeImage_GetFileTypeU(const(wchar)* filename, int size = 0);
FREE_IMAGE_FORMAT  FreeImage_GetFileTypeFromHandle(FreeImageIO *io, fi_handle handle, int size = 0);
FREE_IMAGE_FORMAT  FreeImage_GetFileTypeFromMemory(FIMEMORY *stream, int size = 0);

// Image type request routine -----------------------------------------------

FREE_IMAGE_TYPE  FreeImage_GetImageType(FIBITMAP *dib);

// FreeImage helper routines ------------------------------------------------

BOOL  FreeImage_IsLittleEndian();
BOOL  FreeImage_LookupX11Color(const(char)* szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue);
BOOL  FreeImage_LookupSVGColor(const(char)* szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue);

// Pixel access routines ----------------------------------------------------

BYTE * FreeImage_GetBits(FIBITMAP *dib);
BYTE * FreeImage_GetScanLine(FIBITMAP *dib, int scanline);

BOOL  FreeImage_GetPixelIndex(FIBITMAP *dib, uint x, uint y, BYTE *value);
BOOL  FreeImage_GetPixelColor(FIBITMAP *dib, uint x, uint y, RGBQUAD *value);
BOOL  FreeImage_SetPixelIndex(FIBITMAP *dib, uint x, uint y, BYTE *value);
BOOL  FreeImage_SetPixelColor(FIBITMAP *dib, uint x, uint y, RGBQUAD *value);

// DIB info routines --------------------------------------------------------

uint  FreeImage_GetColorsUsed(FIBITMAP *dib);
uint  FreeImage_GetBPP(FIBITMAP *dib);
uint  FreeImage_GetWidth(FIBITMAP *dib);
uint  FreeImage_GetHeight(FIBITMAP *dib);
uint  FreeImage_GetLine(FIBITMAP *dib);
uint  FreeImage_GetPitch(FIBITMAP *dib);
uint  FreeImage_GetDIBSize(FIBITMAP *dib);
RGBQUAD * FreeImage_GetPalette(FIBITMAP *dib);

uint  FreeImage_GetDotsPerMeterX(FIBITMAP *dib);
uint  FreeImage_GetDotsPerMeterY(FIBITMAP *dib);
void  FreeImage_SetDotsPerMeterX(FIBITMAP *dib, uint res);
void  FreeImage_SetDotsPerMeterY(FIBITMAP *dib, uint res);

BITMAPINFOHEADER * FreeImage_GetInfoHeader(FIBITMAP *dib);
BITMAPINFO * FreeImage_GetInfo(FIBITMAP *dib);
FREE_IMAGE_COLOR_TYPE  FreeImage_GetColorType(FIBITMAP *dib);

uint  FreeImage_GetRedMask(FIBITMAP *dib);
uint  FreeImage_GetGreenMask(FIBITMAP *dib);
uint  FreeImage_GetBlueMask(FIBITMAP *dib);

uint  FreeImage_GetTransparencyCount(FIBITMAP *dib);
BYTE *  FreeImage_GetTransparencyTable(FIBITMAP *dib);
void  FreeImage_SetTransparent(FIBITMAP *dib, BOOL enabled);
void  FreeImage_SetTransparencyTable(FIBITMAP *dib, BYTE *table, int count);
BOOL  FreeImage_IsTransparent(FIBITMAP *dib);
void  FreeImage_SetTransparentIndex(FIBITMAP *dib, int index);
int  FreeImage_GetTransparentIndex(FIBITMAP *dib);

BOOL  FreeImage_HasBackgroundColor(FIBITMAP *dib);
BOOL  FreeImage_GetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor);
BOOL  FreeImage_SetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor);

FIBITMAP * FreeImage_GetThumbnail(FIBITMAP *dib);
BOOL  FreeImage_SetThumbnail(FIBITMAP *dib, FIBITMAP *thumbnail);

// ICC profile routines -----------------------------------------------------

FIICCPROFILE * FreeImage_GetICCProfile(FIBITMAP *dib);
FIICCPROFILE * FreeImage_CreateICCProfile(FIBITMAP *dib, void *data, long size);
void  FreeImage_DestroyICCProfile(FIBITMAP *dib);

// Line conversion routines -------------------------------------------------

void  FreeImage_ConvertLine1To4(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine8To4(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine16To4_555(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine16To4_565(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine24To4(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine32To4(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine1To8(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine4To8(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine16To8_555(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine16To8_565(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine24To8(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine32To8(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine1To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine4To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine8To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine16_565_To16_555(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine24To16_555(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine32To16_555(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine1To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine4To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine8To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine16_555_To16_565(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine24To16_565(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine32To16_565(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine1To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine4To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine8To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine16To24_555(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine16To24_565(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine32To24(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine1To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine4To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine8To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
void  FreeImage_ConvertLine16To32_555(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine16To32_565(BYTE *target, BYTE *source, int width_in_pixels);
void  FreeImage_ConvertLine24To32(BYTE *target, BYTE *source, int width_in_pixels);

// Smart conversion routines ------------------------------------------------

FIBITMAP * FreeImage_ConvertTo4Bits(FIBITMAP *dib);
FIBITMAP * FreeImage_ConvertTo8Bits(FIBITMAP *dib);
FIBITMAP * FreeImage_ConvertToGreyscale(FIBITMAP *dib);
FIBITMAP * FreeImage_ConvertTo16Bits555(FIBITMAP *dib);
FIBITMAP * FreeImage_ConvertTo16Bits565(FIBITMAP *dib);
FIBITMAP * FreeImage_ConvertTo24Bits(FIBITMAP *dib);
FIBITMAP * FreeImage_ConvertTo32Bits(FIBITMAP *dib);
FIBITMAP * FreeImage_ColorQuantize(FIBITMAP *dib, FREE_IMAGE_QUANTIZE quantize);
FIBITMAP * FreeImage_ColorQuantizeEx(FIBITMAP *dib, FREE_IMAGE_QUANTIZE quantize = FIQ_WUQUANT, int PaletteSize = 256, int ReserveSize = 0, RGBQUAD *ReservePalette = NULL);
FIBITMAP * FreeImage_Threshold(FIBITMAP *dib, BYTE T);
FIBITMAP * FreeImage_Dither(FIBITMAP *dib, FREE_IMAGE_DITHER algorithm);

FIBITMAP * FreeImage_ConvertFromRawBits(BYTE *bits, int width, int height, int pitch, uint bpp, uint red_mask, uint green_mask, uint blue_mask, BOOL topdown = FALSE);
void  FreeImage_ConvertToRawBits(BYTE *bits, FIBITMAP *dib, int pitch, uint bpp, uint red_mask, uint green_mask, uint blue_mask, BOOL topdown = FALSE);

FIBITMAP * FreeImage_ConvertToFloat(FIBITMAP *dib);
FIBITMAP * FreeImage_ConvertToRGBF(FIBITMAP *dib);
FIBITMAP * FreeImage_ConvertToUINT16(FIBITMAP *dib);
FIBITMAP * FreeImage_ConvertToRGB16(FIBITMAP *dib);

FIBITMAP * FreeImage_ConvertToStandardType(FIBITMAP *src, BOOL scale_linear = TRUE);
FIBITMAP * FreeImage_ConvertToType(FIBITMAP *src, FREE_IMAGE_TYPE dst_type, BOOL scale_linear = TRUE);

// Tone mapping operators ---------------------------------------------------

FIBITMAP * FreeImage_ToneMapping(FIBITMAP *dib, FREE_IMAGE_TMO tmo, double first_param = 0, double second_param = 0);
FIBITMAP * FreeImage_TmoDrago03(FIBITMAP *src, double gamma = 2.2, double exposure = 0);
FIBITMAP * FreeImage_TmoReinhard05(FIBITMAP *src, double intensity = 0, double contrast = 0);
FIBITMAP * FreeImage_TmoReinhard05Ex(FIBITMAP *src, double intensity = 0, double contrast = 0, double adaptation = 1, double color_correction = 0);

FIBITMAP * FreeImage_TmoFattal02(FIBITMAP *src, double color_saturation = 0.5, double attenuation = 0.85);

// ZLib interface -----------------------------------------------------------

DWORD  FreeImage_ZLibCompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD  FreeImage_ZLibUncompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD  FreeImage_ZLibGZip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD  FreeImage_ZLibGUnzip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
DWORD  FreeImage_ZLibCRC32(DWORD crc, BYTE *source, DWORD source_size);

// --------------------------------------------------------------------------
// Metadata routines
// --------------------------------------------------------------------------

// tag creation / destruction
FITAG * FreeImage_CreateTag();
void  FreeImage_DeleteTag(FITAG *tag);
FITAG * FreeImage_CloneTag(FITAG *tag);

// tag getters and setters
const(char)*  FreeImage_GetTagKey(FITAG *tag);
const(char)*  FreeImage_GetTagDescription(FITAG *tag);
WORD  FreeImage_GetTagID(FITAG *tag);
FREE_IMAGE_MDTYPE  FreeImage_GetTagType(FITAG *tag);
DWORD  FreeImage_GetTagCount(FITAG *tag);
DWORD  FreeImage_GetTagLength(FITAG *tag);
const(void)*  FreeImage_GetTagValue(FITAG *tag);

BOOL  FreeImage_SetTagKey(FITAG *tag, const(char)* key);
BOOL  FreeImage_SetTagDescription(FITAG *tag, const(char)* description);
BOOL  FreeImage_SetTagID(FITAG *tag, WORD id);
BOOL  FreeImage_SetTagType(FITAG *tag, FREE_IMAGE_MDTYPE type);
BOOL  FreeImage_SetTagCount(FITAG *tag, DWORD count);
BOOL  FreeImage_SetTagLength(FITAG *tag, DWORD length);
BOOL  FreeImage_SetTagValue(FITAG *tag, const(void)* value);

// iterator
FIMETADATA * FreeImage_FindFirstMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, FITAG **tag);
BOOL  FreeImage_FindNextMetadata(FIMETADATA *mdhandle, FITAG **tag);
void  FreeImage_FindCloseMetadata(FIMETADATA *mdhandle);

// metadata setter and getter
BOOL  FreeImage_SetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, const(char)* key, FITAG *tag);
BOOL  FreeImage_GetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, const(char)* key, FITAG **tag);

// helpers
uint  FreeImage_GetMetadataCount(FREE_IMAGE_MDMODEL model, FIBITMAP *dib);
BOOL  FreeImage_CloneMetadata(FIBITMAP *dst, FIBITMAP *src);

// tag to C string conversion
const(char)* FreeImage_TagToString(FREE_IMAGE_MDMODEL model, FITAG *tag, char *Make = NULL);

// --------------------------------------------------------------------------
// JPEG lossless transformation routines
// --------------------------------------------------------------------------

BOOL  FreeImage_JPEGTransform(const(char)* src_file, const(char)* dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect = TRUE);
BOOL  FreeImage_JPEGTransformU(const(wchar)* src_file, const(wchar)* dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect = TRUE);
BOOL  FreeImage_JPEGCrop(const(char)* src_file, const(char)* dst_file, int left, int top, int right, int bottom);
BOOL  FreeImage_JPEGCropU(const(wchar)* src_file, const(wchar)* dst_file, int left, int top, int right, int bottom);
BOOL  FreeImage_JPEGTransformFromHandle(FreeImageIO* src_io, fi_handle src_handle, FreeImageIO* dst_io, fi_handle dst_handle, FREE_IMAGE_JPEG_OPERATION operation, int* left, int* top, int* right, int* bottom, BOOL perfect = TRUE);
BOOL  FreeImage_JPEGTransformCombined(const(char)* src_file, const(char)* dst_file, FREE_IMAGE_JPEG_OPERATION operation, int* left, int* top, int* right, int* bottom, BOOL perfect = TRUE);
BOOL  FreeImage_JPEGTransformCombinedU(const(wchar)* src_file, const(wchar)* dst_file, FREE_IMAGE_JPEG_OPERATION operation, int* left, int* top, int* right, int* bottom, BOOL perfect = TRUE);
BOOL  FreeImage_JPEGTransformCombinedFromMemory(FIMEMORY* src_stream, FIMEMORY* dst_stream, FREE_IMAGE_JPEG_OPERATION operation, int* left, int* top, int* right, int* bottom, BOOL perfect = TRUE);


// --------------------------------------------------------------------------
// Image manipulation toolkit
// --------------------------------------------------------------------------

// rotation and flipping
/// @deprecated see FreeImage_Rotate
FIBITMAP * FreeImage_RotateClassic(FIBITMAP *dib, double angle);
FIBITMAP * FreeImage_Rotate(FIBITMAP *dib, double angle, const(void)* bkcolor = NULL);
FIBITMAP * FreeImage_RotateEx(FIBITMAP *dib, double angle, double x_shift, double y_shift, double x_origin, double y_origin, BOOL use_mask);
BOOL  FreeImage_FlipHorizontal(FIBITMAP *dib);
BOOL  FreeImage_FlipVertical(FIBITMAP *dib);

// upsampling / downsampling
FIBITMAP * FreeImage_Rescale(FIBITMAP *dib, int dst_width, int dst_height, FREE_IMAGE_FILTER filter = FILTER_CATMULLROM);
FIBITMAP * FreeImage_MakeThumbnail(FIBITMAP *dib, int max_pixel_size, BOOL convert = TRUE);

// color manipulation routines (point operations)
BOOL  FreeImage_AdjustCurve(FIBITMAP *dib, BYTE *LUT, FREE_IMAGE_COLOR_CHANNEL channel);
BOOL  FreeImage_AdjustGamma(FIBITMAP *dib, double gamma);
BOOL  FreeImage_AdjustBrightness(FIBITMAP *dib, double percentage);
BOOL  FreeImage_AdjustContrast(FIBITMAP *dib, double percentage);
BOOL  FreeImage_Invert(FIBITMAP *dib);
BOOL  FreeImage_GetHistogram(FIBITMAP *dib, DWORD *histo, FREE_IMAGE_COLOR_CHANNEL channel = FICC_BLACK);
int  FreeImage_GetAdjustColorsLookupTable(BYTE *LUT, double brightness, double contrast, double gamma, BOOL invert);
BOOL  FreeImage_AdjustColors(FIBITMAP *dib, double brightness, double contrast, double gamma, BOOL invert = FALSE);
uint  FreeImage_ApplyColorMapping(FIBITMAP *dib, RGBQUAD *srccolors, RGBQUAD *dstcolors, uint count, BOOL ignore_alpha, BOOL swap);
uint  FreeImage_SwapColors(FIBITMAP *dib, RGBQUAD *color_a, RGBQUAD *color_b, BOOL ignore_alpha);
uint  FreeImage_ApplyPaletteIndexMapping(FIBITMAP *dib, BYTE *srcindices,	BYTE *dstindices, uint count, BOOL swap);
uint  FreeImage_SwapPaletteIndices(FIBITMAP *dib, BYTE *index_a, BYTE *index_b);

// channel processing routines
FIBITMAP * FreeImage_GetChannel(FIBITMAP *dib, FREE_IMAGE_COLOR_CHANNEL channel);
BOOL  FreeImage_SetChannel(FIBITMAP *dst, FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);
FIBITMAP * FreeImage_GetComplexChannel(FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);
BOOL  FreeImage_SetComplexChannel(FIBITMAP *dst, FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);

// copy / paste / composite routines
FIBITMAP * FreeImage_Copy(FIBITMAP *dib, int left, int top, int right, int bottom);
BOOL  FreeImage_Paste(FIBITMAP *dst, FIBITMAP *src, int left, int top, int alpha);
FIBITMAP * FreeImage_Composite(FIBITMAP *fg, BOOL useFileBkg = FALSE, RGBQUAD *appBkColor = NULL, FIBITMAP *bg = NULL);
BOOL  FreeImage_PreMultiplyWithAlpha(FIBITMAP *dib);

// background filling routines
BOOL  FreeImage_FillBackground(FIBITMAP *dib, const(void)* color, int options = 0);
FIBITMAP * FreeImage_EnlargeCanvas(FIBITMAP *src, int left, int top, int right, int bottom, const(void)* color, int options = 0);
FIBITMAP * FreeImage_AllocateEx(int width, int height, int bpp, const(RGBQUAD)* color, int options = 0, const(RGBQUAD)* palette = NULL, uint red_mask = 0, uint green_mask = 0, uint blue_mask = 0);
FIBITMAP * FreeImage_AllocateExT(FREE_IMAGE_TYPE type, int width, int height, int bpp, const(void)* color, int options = 0, const(RGBQUAD)* palette = NULL, uint red_mask = 0, uint green_mask = 0, uint blue_mask = 0);

// miscellaneous algorithms
FIBITMAP * FreeImage_MultigridPoissonSolver(FIBITMAP *Laplacian, int ncycle = 3);

// restore the borland-specific enum size option
// #if defined(__BORLANDC__)
// #pragma option pop
// #endif
//
// #ifdef __cplusplus
// }
// #endif
//
// #endif // FREEIMAGE_H
