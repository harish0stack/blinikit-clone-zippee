// src/features/catalog/AddEditProductModal.tsx
import React, { useState, useEffect } from "react";
import { useAuth } from "../auth/AuthContext";
import { supabase } from "../../lib/supabaseClient";
import { ProductImageCropper } from "./components/ProductImageCropper";

interface AddEditProductModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSuccess: () => void;
  editingProduct?: any;
  initialImageFile?: File | null;
}

interface CategoryOption {
  id: string;
  name: string;
  slug: string;
}

export const AddEditProductModal: React.FC<AddEditProductModalProps> = ({
  isOpen,
  onClose,
  onSuccess,
  editingProduct,
  initialImageFile,
}) => {
  const { vendor } = useAuth();

  const [categories, setCategories] = useState<CategoryOption[]>([]);
  const [name, setName] = useState("");
  const [categoryId, setCategoryId] = useState("");
  const [unit, setUnit] = useState("1 unit");
  const [mrp, setMrp] = useState<number | "">("");
  const [sellingPrice, setSellingPrice] = useState<number | "">("");
  const [stockQty, setStockQty] = useState<number>(100);

  // Image Upload state
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string>("");
  const [tempImageSrc, setTempImageSrc] = useState<string | null>(null);
  const [isCropperOpen, setIsCropperOpen] = useState(false);

  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Fetch active categories
    async function loadCategories() {
      const { data } = await supabase
        .from("categories")
        .select("id, name, slug")
        .eq("is_active", true)
        .order("sort_order");

      if (data && data.length > 0) {
        setCategories(data);
        if (!editingProduct) {
          setCategoryId(data[0].id);
        }
      }
    }
    loadCategories();
  }, [editingProduct]);

  useEffect(() => {
    if (editingProduct) {
      setName(editingProduct.name || "");
      setCategoryId(editingProduct.category_id || "");
      setUnit(editingProduct.unit || "1 unit");
      setMrp(editingProduct.mrp || "");
      setSellingPrice(editingProduct.selling_price || "");
      setStockQty(editingProduct.stock_qty ?? 100);
      setImagePreview(editingProduct.product_images?.[0]?.webp_url || "");
    } else {
      setName("");
      setUnit("500 g");
      setMrp("");
      setSellingPrice("");
      setStockQty(100);
      setImageFile(null);
      setImagePreview("");
    }
    setError(null);
  }, [editingProduct, isOpen]);

  // Drag & drop state
  const [isDraggingOver, setIsDraggingOver] = useState(false);

  const processImageFile = (file: File) => {
    if (!file.type.startsWith("image/")) {
      setError("Please select a valid image file (PNG, JPG, WebP, JPEG).");
      return;
    }

    const reader = new FileReader();
    reader.onload = () => {
      setTempImageSrc(reader.result as string);
      setIsCropperOpen(true);
    };
    reader.readAsDataURL(file);
  };

  useEffect(() => {
    if (initialImageFile && isOpen) {
      processImageFile(initialImageFile);
    }
  }, [initialImageFile, isOpen]);

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      processImageFile(file);
    }
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (!isDraggingOver) {
      setIsDraggingOver(true);
    }
  };

  const handleDragEnter = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDraggingOver(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    // Only reset if left the container
    if (e.currentTarget.contains(e.relatedTarget as Node)) return;
    setIsDraggingOver(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDraggingOver(false);

    const files = e.dataTransfer.files;
    if (files && files.length > 0) {
      processImageFile(files[0]);
    }
  };

  const handleCropComplete = (croppedFile: File, previewUrl: string) => {
    setImageFile(croppedFile);
    setImagePreview(previewUrl);
    setIsCropperOpen(false);
    setTempImageSrc(null);
  };

  const discountPercent =
    typeof mrp === "number" && typeof sellingPrice === "number" && mrp > 0 && sellingPrice < mrp
      ? Math.round(((mrp - sellingPrice) / mrp) * 100)
      : 0;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!vendor?.id) {
      setError("Vendor account not found.");
      return;
    }
    if (!name.trim()) {
      setError("Please enter a product name.");
      return;
    }
    if (!categoryId) {
      setError("Please select a category.");
      return;
    }
    if (typeof mrp !== "number" || mrp <= 0) {
      setError("Please enter a valid MRP greater than 0.");
      return;
    }
    if (typeof sellingPrice !== "number" || sellingPrice <= 0) {
      setError("Please enter a valid Selling Price greater than 0.");
      return;
    }
    if (sellingPrice > mrp) {
      setError("Selling Price cannot be greater than MRP.");
      return;
    }
    if (!editingProduct && !imageFile && !imagePreview) {
      setError("Please upload at least 1 product image.");
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      let productId = editingProduct?.id;

      if (editingProduct) {
        // Update product
        const { error: updateError } = await supabase
          .from("products")
          .update({
            name: name.trim(),
            category_id: categoryId,
            unit: unit.trim(),
            mrp: mrp,
            selling_price: sellingPrice,
            stock_qty: stockQty,
            updated_at: new Date().toISOString(),
          })
          .eq("id", productId);

        if (updateError) throw updateError;
      } else {
        // Insert product
        const { data: newProd, error: insertError } = await supabase
          .from("products")
          .insert({
            vendor_id: vendor.id,
            category_id: categoryId,
            name: name.trim(),
            unit: unit.trim(),
            mrp: mrp,
            selling_price: sellingPrice,
            stock_qty: stockQty,
            status: "live",
          })
          .select("id")
          .single();

        if (insertError) throw insertError;
        productId = newProd.id;
      }

      // Handle Image Upload if a new file was cropped
      let uploadedImageUrl = "";
      if (imageFile && productId) {
        const categorySlug = categories.find((c) => c.id === categoryId)?.slug || "general";
        const filePath = `${categorySlug}/${vendor.id}_${crypto.randomUUID()}.webp`;

        const { error: uploadError } = await supabase.storage
          .from("product-images")
          .upload(filePath, imageFile, {
            contentType: "image/webp",
            upsert: true,
          });

        if (!uploadError) {
          const { data: { publicUrl } } = supabase.storage
            .from("product-images")
            .getPublicUrl(filePath);

          uploadedImageUrl = publicUrl;

          await supabase.from("product_images").insert({
            product_id: productId,
            webp_url: publicUrl,
            is_primary: true,
            sort_order: 0,
          });
        } else {
          console.warn("Storage upload note:", uploadError.message);
        }
      }

      // Dispatch real-time push notification to all consumer devices for new product uploads
      if (!editingProduct && productId) {
        supabase.functions
          .invoke("send-push-notification", {
            body: {
              productId,
              productName: name.trim(),
              vendorBusinessName: vendor.business_name,
              sellingPrice: sellingPrice,
              unit: unit.trim(),
              imageUrl: uploadedImageUrl,
            },
          })
          .catch((pushErr) => {
            console.warn("Push notification dispatch warning:", pushErr);
          });
      }

      onSuccess();
      onClose();
    } catch (err: any) {
      console.error("Save Product Error:", err);
      setError(err?.message || "Failed to save product.");
    } finally {
      setIsLoading(false);
    }
  };

  // ESC key to close modal
  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape" && !isCropperOpen) {
        onClose();
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, [isOpen, isCropperOpen, onClose]);

  if (!isOpen) return null;

  return (
    <>
      <div
        className="fixed inset-0 z-40 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200"
        onClick={onClose}
      >
        <div
          className="relative w-full max-w-2xl bg-white rounded-2xl shadow-2xl overflow-hidden max-h-[90vh] flex flex-col font-['Lexend',sans-serif] animate-in zoom-in-95 duration-200"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header */}
          <div className="flex items-center justify-between px-6 py-4 border-b border-gray-100 bg-[#F9FAFB]">
            <h3 className="text-xl font-bold text-[#1F1F1F]">
              {editingProduct ? "Edit Product" : "Add New Product"}
            </h3>
            <button
              type="button"
              onClick={onClose}
              className="p-1.5 text-gray-400 hover:text-gray-700 rounded-full hover:bg-gray-200 transition-colors cursor-pointer"
            >
              <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Form Body */}
          <form onSubmit={handleSubmit} className="p-6 overflow-y-auto space-y-6 flex-1">
            {error && (
              <div className="p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg">
                {error}
              </div>
            )}

            {/* Product Image Box with Interactive Drag and Drop Zone */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="block text-sm font-semibold text-[#1F1F1F]">
                  Product Image (1:1 Aspect Ratio) *
                </label>
                <span className="text-xs font-medium text-[#318616] bg-[#EBFFEF] px-2 py-0.5 rounded-full">
                  Drag & Drop Supported
                </span>
              </div>

              {/* Drag and Drop Container */}
              <div
                onDragOver={handleDragOver}
                onDragEnter={handleDragEnter}
                onDragLeave={handleDragLeave}
                onDrop={handleDrop}
                className={`relative border-2 border-dashed rounded-2xl p-4 transition-all duration-200 flex flex-col sm:flex-row items-center gap-5 ${
                  isDraggingOver
                    ? "border-[#318616] bg-[#EBFFEF]/60 shadow-inner scale-[1.01]"
                    : "border-gray-300 hover:border-gray-400 bg-gray-50/60"
                }`}
              >
                {/* 1:1 Preview Box */}
                <div className="relative w-28 h-28 rounded-xl border border-gray-200 bg-white flex items-center justify-center overflow-hidden shrink-0 shadow-xs">
                  {imagePreview ? (
                    <img
                      src={imagePreview}
                      alt="Product preview"
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="text-center p-2 text-gray-400">
                      <svg className="w-8 h-8 mx-auto stroke-current" fill="none" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                      </svg>
                      <span className="text-[10px] block mt-1">1:1 Square</span>
                    </div>
                  )}

                  {isDraggingOver && (
                    <div className="absolute inset-0 bg-[#318616]/20 flex items-center justify-center backdrop-blur-[1px]">
                      <svg className="w-8 h-8 text-[#318616] animate-bounce" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 14l-7 7m0 0l-7-7m7 7V3" />
                      </svg>
                    </div>
                  )}
                </div>

                {/* Dropzone Instructions & File Trigger */}
                <div className="flex-1 text-center sm:text-left space-y-2">
                  <div className="text-sm font-semibold text-gray-800">
                    {isDraggingOver ? (
                      <span className="text-[#318616]">Release to crop & upload photo</span>
                    ) : (
                      <span>Drag & drop your product image here, or browse</span>
                    )}
                  </div>

                  <div className="flex flex-wrap items-center gap-3 justify-center sm:justify-start">
                    <label className="inline-flex items-center gap-2 px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm font-semibold text-gray-700 hover:bg-gray-50 shadow-xs cursor-pointer active:scale-95 transition-all">
                      <svg className="w-4 h-4 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
                      </svg>
                      <span>{imagePreview ? "Change Photo" : "Browse Files"}</span>
                      <input
                        type="file"
                        accept="image/*"
                        onChange={handleFileSelect}
                        className="hidden"
                      />
                    </label>

                    {imagePreview && (
                      <button
                        type="button"
                        onClick={() => {
                          setImageFile(null);
                          setImagePreview("");
                        }}
                        className="text-xs text-red-600 hover:underline font-medium cursor-pointer"
                      >
                        Remove
                      </button>
                    )}
                  </div>

                  <p className="text-xs text-gray-500">
                    Supports JPG, PNG, WebP. Compressed automatically (≤300KB) with instant 1:1 square crop.
                  </p>
                </div>
              </div>
            </div>

            {/* Product Name */}
            <div>
              <label className="block text-sm font-semibold text-[#1F1F1F] mb-1.5">
                Product Name *
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="e.g. Amul Taaza Homogenised Toned Milk"
                required
                className="w-full h-11 px-3.5 rounded-lg border border-gray-300 text-sm text-[#1F1F1F] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 font-medium"
              />
            </div>

            {/* Category & Unit Row */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-semibold text-[#1F1F1F] mb-1.5">
                  Category *
                </label>
                <select
                  value={categoryId}
                  onChange={(e) => setCategoryId(e.target.value)}
                  className="w-full h-11 px-3.5 rounded-lg border border-gray-300 text-sm text-[#1F1F1F] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 font-medium bg-white"
                >
                  {categories.map((cat) => (
                    <option key={cat.id} value={cat.id}>
                      {cat.name}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-sm font-semibold text-[#1F1F1F] mb-1.5">
                  Unit / Quantity *
                </label>
                <input
                  type="text"
                  value={unit}
                  onChange={(e) => setUnit(e.target.value)}
                  placeholder="e.g. 500 ml, 1 kg, 1 pack"
                  required
                  className="w-full h-11 px-3.5 rounded-lg border border-gray-300 text-sm text-[#1F1F1F] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 font-medium"
                />
              </div>
            </div>

            {/* Pricing Row: MRP, Selling Price, Discount */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div>
                <label className="block text-sm font-semibold text-[#1F1F1F] mb-1.5">
                  MRP (₹) *
                </label>
                <input
                  type="number"
                  step="0.01"
                  min="1"
                  value={mrp}
                  onChange={(e) => setMrp(e.target.value === "" ? "" : Number(e.target.value))}
                  placeholder="30.00"
                  required
                  className="w-full h-11 px-3.5 rounded-lg border border-gray-300 text-sm text-[#1F1F1F] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 font-medium"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-[#1F1F1F] mb-1.5">
                  Selling Price (₹) *
                </label>
                <input
                  type="number"
                  step="0.01"
                  min="1"
                  value={sellingPrice}
                  onChange={(e) =>
                    setSellingPrice(e.target.value === "" ? "" : Number(e.target.value))
                  }
                  placeholder="28.00"
                  required
                  className="w-full h-11 px-3.5 rounded-lg border border-gray-300 text-sm text-[#1F1F1F] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 font-medium"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-500 mb-1.5">
                  Discount Badge
                </label>
                <div className="h-11 px-3.5 rounded-lg bg-emerald-50 border border-emerald-200 flex items-center font-bold text-emerald-800 text-sm">
                  {discountPercent > 0 ? `${discountPercent}% OFF` : "No discount"}
                </div>
              </div>
            </div>

            {/* Stock Quantity */}
            <div>
              <label className="block text-sm font-semibold text-[#1F1F1F] mb-1.5">
                Initial Stock Quantity *
              </label>
              <input
                type="number"
                min="0"
                value={stockQty}
                onChange={(e) => setStockQty(Number(e.target.value))}
                required
                className="w-full max-w-xs h-11 px-3.5 rounded-lg border border-gray-300 text-sm text-[#1F1F1F] focus:outline-none focus:border-[#318616] focus:ring-2 focus:ring-[#318616]/20 font-medium"
              />
            </div>

            {/* Form Footer Actions */}
            <div className="pt-4 border-t border-gray-100 flex items-center justify-end gap-3">
              <button
                type="button"
                onClick={onClose}
                className="px-5 py-2.5 text-sm font-medium text-gray-600 hover:bg-gray-100 rounded-lg cursor-pointer"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={isLoading}
                className="px-6 py-2.5 bg-[#318616] hover:bg-[#286f12] active:scale-95 text-white font-semibold text-sm rounded-lg shadow-md transition-all cursor-pointer flex items-center gap-2"
              >
                {isLoading ? "Saving Product..." : editingProduct ? "Update Product" : "Publish to Catalog"}
              </button>
            </div>
          </form>
        </div>
      </div>

      {/* 1:1 Square Cropper Modal */}
      {isCropperOpen && tempImageSrc && (
        <ProductImageCropper
          imageSrc={tempImageSrc}
          onCropComplete={handleCropComplete}
          onCancel={() => {
            setIsCropperOpen(false);
            setTempImageSrc(null);
          }}
        />
      )}
    </>
  );
};
