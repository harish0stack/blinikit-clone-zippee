// src/lib/imageCompression.ts
// STUB: full implementation in Phase 5 (Vendor Catalog Upload)
// Target: WebP, 150–300 KB, using browser-image-compression
import imageCompression from "browser-image-compression";

export const DEFAULT_COMPRESSION_OPTIONS = {
  maxSizeMB: 0.3,          // 300 KB upper bound
  maxWidthOrHeight: 1024,
  useWebWorker: true,
  fileType: "image/webp",
} as const;

// eslint-disable-next-line @typescript-eslint/no-unused-vars
export async function compressImage(_file: File): Promise<File> {
  // TODO Phase 5: implement full compression pipeline
  throw new Error("compressImage is not yet implemented — Phase 5");
}

export { imageCompression };
