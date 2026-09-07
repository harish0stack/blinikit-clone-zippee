// src/features/catalog/components/ProductImageCropper.tsx
import React, { useState, useCallback } from "react";
import Cropper from "react-easy-crop";
import type { Area } from "react-easy-crop";
import imageCompression from "browser-image-compression";

interface ProductImageCropperProps {
  imageSrc: string;
  onCropComplete: (file: File, previewUrl: string) => void;
  onCancel: () => void;
}

export const ProductImageCropper: React.FC<ProductImageCropperProps> = ({
  imageSrc,
  onCropComplete,
  onCancel,
}) => {
  const [crop, setCrop] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [croppedAreaPixels, setCroppedAreaPixels] = useState<Area | null>(null);
  const [isCompressing, setIsCompressing] = useState(false);

  const onCropChange = (newCrop: { x: number; y: number }) => {
    setCrop(newCrop);
  };

  const onCropCompleteHandler = useCallback((_croppedArea: Area, croppedPixels: Area) => {
    setCroppedAreaPixels(croppedPixels);
  }, []);

  const createImage = (url: string): Promise<HTMLImageElement> =>
    new Promise((resolve, reject) => {
      const image = new Image();
      image.addEventListener("load", () => resolve(image));
      image.addEventListener("error", (error) => reject(error));
      image.setAttribute("crossOrigin", "anonymous");
      image.src = url;
    });

  const getCroppedImg = async (imageSrc: string, pixelCrop: Area): Promise<Blob> => {
    const image = await createImage(imageSrc);
    const canvas = document.createElement("canvas");
    const ctx = canvas.getContext("2d");

    if (!ctx) {
      throw new Error("No 2d context");
    }

    canvas.width = pixelCrop.width;
    canvas.height = pixelCrop.height;

    ctx.drawImage(
      image,
      pixelCrop.x,
      pixelCrop.y,
      pixelCrop.width,
      pixelCrop.height,
      0,
      0,
      pixelCrop.width,
      pixelCrop.height
    );

    return new Promise((resolve, reject) => {
      canvas.toBlob((blob) => {
        if (!blob) {
          reject(new Error("Canvas is empty"));
          return;
        }
        resolve(blob);
      }, "image/webp", 0.9);
    });
  };

  const handleSaveCrop = async () => {
    if (!croppedAreaPixels) return;

    setIsCompressing(true);
    try {
      const croppedBlob = await getCroppedImg(imageSrc, croppedAreaPixels);
      const rawFile = new File([croppedBlob], "product-image.webp", { type: "image/webp" });

      // Client-side compression targeting <= 300KB
      const compressedFile = await imageCompression(rawFile, {
        maxSizeMB: 0.3,
        maxWidthOrHeight: 1024,
        useWebWorker: true,
        fileType: "image/webp",
      });

      const previewUrl = URL.createObjectURL(compressedFile);
      onCropComplete(compressedFile, previewUrl);
    } catch (err) {
      console.error("Image Crop / Compression Error:", err);
    } finally {
      setIsCompressing(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-xs">
      <div className="bg-white rounded-2xl p-6 w-full max-w-lg shadow-2xl flex flex-col items-center">
        <h3 className="text-lg font-bold text-[#1F1F1F] mb-1">
          Crop Product Image (1:1 Ratio)
        </h3>
        <p className="text-xs text-gray-500 mb-4 text-center">
          Position and zoom your product photo for the consumer app catalog
        </p>

        <div className="relative w-full h-72 bg-black rounded-xl overflow-hidden">
          <Cropper
            image={imageSrc}
            crop={crop}
            zoom={zoom}
            aspect={1}
            onCropChange={onCropChange}
            onCropComplete={onCropCompleteHandler}
            onZoomChange={setZoom}
          />
        </div>

        {/* Zoom Slider */}
        <div className="w-full mt-4 flex items-center gap-3">
          <span className="text-xs text-gray-500 font-medium">Zoom</span>
          <input
            type="range"
            value={zoom}
            min={1}
            max={3}
            step={0.1}
            aria-labelledby="Zoom"
            onChange={(e) => setZoom(Number(e.target.value))}
            className="w-full accent-[#318616]"
          />
        </div>

        {/* Action Buttons */}
        <div className="flex items-center justify-end gap-3 w-full mt-6">
          <button
            type="button"
            onClick={onCancel}
            className="px-4 py-2 text-sm font-medium text-gray-600 hover:bg-gray-100 rounded-lg cursor-pointer"
          >
            Cancel
          </button>
          <button
            type="button"
            onClick={handleSaveCrop}
            disabled={isCompressing}
            className="px-6 py-2 text-sm font-semibold text-white bg-[#318616] hover:bg-[#286f12] active:scale-95 rounded-lg shadow-md transition-all cursor-pointer flex items-center gap-2"
          >
            {isCompressing ? "Compressing WebP..." : "Apply & Upload"}
          </button>
        </div>
      </div>
    </div>
  );
};
