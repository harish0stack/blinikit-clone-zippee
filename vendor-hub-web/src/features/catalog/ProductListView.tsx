// src/features/catalog/ProductListView.tsx
import React, { useState, useEffect } from "react";
import { useAuth } from "../auth/AuthContext";
import { supabase } from "../../lib/supabaseClient";
import { AddEditProductModal } from "./AddEditProductModal";

export const ProductListView: React.FC = () => {
  const { vendor } = useAuth();
  const [products, setProducts] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState<any | null>(null);
  const [droppedImageFile, setDroppedImageFile] = useState<File | null>(null);
  const [isDraggingOverPage, setIsDraggingOverPage] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");

  const fetchProducts = async () => {
    if (!vendor?.id) return;
    setIsLoading(true);
    try {
      const { data, error } = await supabase
        .from("products")
        .select(`
          *,
          categories(name, slug),
          product_images(id, webp_url, is_primary)
        `)
        .eq("vendor_id", vendor.id)
        .order("created_at", { ascending: false });

      if (error) {
        console.error("Fetch products error:", error);
      } else {
        setProducts(data || []);
      }
    } catch (err) {
      console.error("Error loading products:", err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchProducts();
  }, [vendor?.id]);

  const handleOpenAdd = (file?: File) => {
    setEditingProduct(null);
    setDroppedImageFile(file || null);
    setIsModalOpen(true);
  };

  const handleOpenEdit = (product: any) => {
    setEditingProduct(product);
    setDroppedImageFile(null);
    setIsModalOpen(true);
  };

  const handlePageDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (!isDraggingOverPage) {
      setIsDraggingOverPage(true);
    }
  };

  const handlePageDragEnter = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDraggingOverPage(true);
  };

  const handlePageDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.currentTarget.contains(e.relatedTarget as Node)) return;
    setIsDraggingOverPage(false);
  };

  const handlePageDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDraggingOverPage(false);

    const files = e.dataTransfer.files;
    if (files && files.length > 0 && files[0].type.startsWith("image/")) {
      handleOpenAdd(files[0]);
    }
  };

  const filteredProducts = products.filter((p) =>
    p.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div
      onDragOver={handlePageDragOver}
      onDragEnter={handlePageDragEnter}
      onDragLeave={handlePageDragLeave}
      onDrop={handlePageDrop}
      className="p-6 md:p-10 max-w-7xl mx-auto space-y-6 relative min-h-[85vh] animate-in fade-in duration-300"
    >
      {/* Full-Page Drag & Drop Overlay Indicator */}
      {isDraggingOverPage && !isModalOpen && (
        <div className="fixed inset-0 z-50 bg-[#233528]/85 backdrop-blur-xs flex flex-col items-center justify-center text-white animate-in fade-in duration-150 pointer-events-none">
          <div className="p-8 rounded-[28px] border-2 border-dashed border-[#FFD455] bg-black/50 flex flex-col items-center gap-4 max-w-md text-center shadow-2xl">
            <div className="w-16 h-16 rounded-full bg-[#FFD455] text-black flex items-center justify-center shadow-lg animate-bounce">
              <svg className="w-8 h-8" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12" />
              </svg>
            </div>
            <div>
              <h2 className="text-xl font-bold text-white tracking-tight">Drop to Upload Product</h2>
              <p className="text-xs text-white/80 mt-1">
                Release your product photo to open the 1:1 square cropper.
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Header & Quick Action Bar */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h1 className="text-2xl font-bold text-[#1F1F1F]">Catalog Products</h1>
            <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-gray-200/80 text-gray-700 font-mono">
              {products.length}
            </span>
          </div>
          <p className="text-xs sm:text-sm text-gray-500 mt-0.5">
            Manage your store inventory, stock levels, and instant 1:1 image uploads
          </p>
        </div>

        {/* Primary Add Button with Nested Button-in-Button */}
        <button
          type="button"
          onClick={() => handleOpenAdd()}
          className="group inline-flex items-center gap-3 px-5 py-2.5 bg-[#318616] hover:bg-[#286f12] active:scale-95 text-white font-bold text-sm rounded-full shadow-md hover:shadow-lg transition-all cursor-pointer self-start sm:self-auto"
        >
          <span>Add Product</span>
          <div className="w-6 h-6 rounded-full bg-white/20 group-hover:bg-[#FFD455] group-hover:text-black flex items-center justify-center transition-all duration-200 group-hover:scale-105">
            <svg className="w-3.5 h-3.5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 4v16m8-8H4" />
            </svg>
          </div>
        </button>
      </div>

      {/* Double-Bezel Drag & Drop Banner */}
      <div className="p-1 rounded-[22px] bg-black/[0.03] ring-1 ring-black/[0.05]">
        <div className="rounded-[18px] bg-gradient-to-r from-[#EBFFEF]/80 to-[#F4F6FB] border border-[#318616]/20 p-5 flex flex-col sm:flex-row items-center justify-between gap-4 shadow-xs">
          <div className="flex items-center gap-4 text-center sm:text-left">
            <div className="w-11 h-11 rounded-xl bg-[#318616] text-white flex items-center justify-center shrink-0 shadow-xs">
              <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
              </svg>
            </div>
            <div>
              <div className="text-sm font-bold text-gray-900">
                Drag & drop product images to upload
              </div>
              <div className="text-xs text-gray-600 mt-0.5">
                Drop any photo (JPG, PNG, WebP) directly into this page to crop & publish.
              </div>
            </div>
          </div>

          <button
            type="button"
            onClick={() => handleOpenAdd()}
            className="px-4 py-2 bg-white hover:bg-gray-50 border border-gray-300 text-gray-800 font-semibold text-xs rounded-xl shadow-2xs active:scale-95 transition-all cursor-pointer shrink-0"
          >
            Upload via File Picker
          </button>
        </div>
      </div>

      {/* Search & Filter Strip */}
      {products.length > 0 && (
        <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
          <div className="relative w-full sm:w-80">
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search products by name..."
              className="w-full h-10 pl-9 pr-4 bg-white border border-gray-200 rounded-xl text-xs font-medium text-gray-800 placeholder:text-gray-400 focus:outline-none focus:border-[#318616] focus:ring-1 focus:ring-[#318616] transition-all shadow-2xs"
            />
            <svg
              className="absolute left-3 top-2.5 w-4 h-4 text-gray-400"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
            >
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
        </div>
      )}

      {/* Product List Table / Grid */}
      {isLoading ? (
        <div className="p-16 text-center bg-white rounded-2xl border border-gray-100 shadow-xs">
          <div className="w-10 h-10 border-3 border-[#318616] border-t-transparent rounded-full animate-spin mx-auto mb-3" />
          <p className="text-xs text-gray-500 font-medium">Syncing catalog items with Dark Store...</p>
        </div>
      ) : filteredProducts.length === 0 ? (
        <div className="p-12 text-center bg-white rounded-[24px] border border-dashed border-gray-200 shadow-xs">
          <div className="w-14 h-14 bg-emerald-50 text-[#318616] rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-2xs">
            <svg className="w-7 h-7" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth={1.5}>
              <path strokeLinecap="round" strokeLinejoin="round" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4" />
            </svg>
          </div>
          <h3 className="text-base font-bold text-[#1F1F1F] mb-1">
            {searchQuery ? "No matching products found" : "No products in your catalog yet"}
          </h3>
          <p className="text-xs text-gray-500 max-w-sm mx-auto mb-6">
            {searchQuery
              ? "Try adjusting your search keywords."
              : "Drag & drop an image or click below to upload your first item for 10-minute delivery."}
          </p>
          {!searchQuery && (
            <button
              type="button"
              onClick={() => handleOpenAdd()}
              className="px-6 py-2.5 bg-[#318616] hover:bg-[#286f12] text-white font-bold text-xs rounded-full shadow-sm active:scale-95 transition-all cursor-pointer"
            >
              Add Your First Product
            </button>
          )}
        </div>
      ) : (
        <div className="p-1 rounded-[24px] bg-black/[0.03] ring-1 ring-black/[0.05]">
          <div className="bg-white rounded-[20px] shadow-sm border border-gray-100 overflow-hidden">
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-[#F9FAFB] border-b border-gray-100 text-[11px] font-bold text-gray-500 uppercase tracking-wider">
                    <th className="py-4 px-6">Product</th>
                    <th className="py-4 px-6">Category</th>
                    <th className="py-4 px-6">Pricing</th>
                    <th className="py-4 px-6">Stock</th>
                    <th className="py-4 px-6">Status</th>
                    <th className="py-4 px-6 text-right">Action</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100 text-sm">
                  {filteredProducts.map((prod) => {
                    const image = prod.product_images?.[0]?.webp_url || "/assets/landing/logo.webp";
                    const discount =
                      prod.mrp > prod.selling_price
                        ? Math.round(((prod.mrp - prod.selling_price) / prod.mrp) * 100)
                        : 0;

                    return (
                      <tr key={prod.id} className="hover:bg-gray-50/80 transition-colors">
                        <td className="py-4 px-6 flex items-center gap-4">
                          <img
                            src={image}
                            alt={prod.name}
                            className="w-12 h-12 object-cover rounded-xl border border-gray-200 shrink-0 bg-white shadow-2xs"
                          />
                          <div>
                            <span className="font-bold text-[#1F1F1F] block line-clamp-1 text-sm">
                              {prod.name}
                            </span>
                            <span className="text-[11px] text-gray-400 font-medium">
                              {prod.unit}
                            </span>
                          </div>
                        </td>

                        <td className="py-4 px-6">
                          <span className="inline-block px-3 py-1 bg-gray-100 text-gray-700 text-xs font-semibold rounded-lg">
                            {prod.categories?.name || "General"}
                          </span>
                        </td>

                        <td className="py-4 px-6">
                          <div className="flex items-baseline gap-2">
                            <span className="font-extrabold text-[#1F1F1F] font-mono">
                              ₹{prod.selling_price}
                            </span>
                            {prod.mrp > prod.selling_price && (
                              <span className="text-xs text-gray-400 line-through font-mono">
                                ₹{prod.mrp}
                              </span>
                            )}
                            {discount > 0 && (
                              <span className="text-[10px] font-bold text-emerald-800 bg-[#EBFFEF] px-1.5 py-0.5 rounded">
                                {discount}% OFF
                              </span>
                            )}
                          </div>
                        </td>

                        <td className="py-4 px-6">
                          <span
                            className={`font-bold text-xs font-mono ${
                              prod.stock_qty > 10 ? "text-gray-700" : "text-amber-600"
                            }`}
                          >
                            {prod.stock_qty} units
                          </span>
                        </td>

                        <td className="py-4 px-6">
                          <span
                            className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold ${
                              prod.status === "live"
                                ? "bg-[#EBFFEF] text-[#318616]"
                                : prod.status === "pending_review"
                                ? "bg-amber-50 text-amber-700"
                                : "bg-gray-100 text-gray-600"
                            }`}
                          >
                            <span
                              className={`w-1.5 h-1.5 rounded-full ${
                                prod.status === "live"
                                  ? "bg-[#318616]"
                                  : prod.status === "pending_review"
                                  ? "bg-amber-500"
                                  : "bg-gray-400"
                              }`}
                            />
                            {prod.status === "live" ? "Live in App" : prod.status}
                          </span>
                        </td>

                        <td className="py-4 px-6 text-right">
                          <button
                            type="button"
                            onClick={() => handleOpenEdit(prod)}
                            className="text-xs font-bold text-[#318616] hover:underline cursor-pointer"
                          >
                            Edit
                          </button>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Add / Edit Product Modal */}
      <AddEditProductModal
        isOpen={isModalOpen}
        editingProduct={editingProduct}
        initialImageFile={droppedImageFile}
        onClose={() => {
          setIsModalOpen(false);
          setDroppedImageFile(null);
        }}
        onSuccess={fetchProducts}
      />
    </div>
  );
};
export default ProductListView;
