# Phase 5 — Vendor Catalog Upload Flow (Full Loop)

> **Session start prompt:**
> ```
> Read: /Users/harishkumavat/blinkit-clone/docs/context/SESSION_CONTEXT.md
> Read: /Users/harishkumavat/blinkit-clone/docs/specs/phase-5-vendor-catalog-upload.md
> Branch: phase-5-vendor-upload
> Phases 0, 1, 2, 3, 4 are COMPLETE.
> ```

---

## Goal

Build the complete vendor product management flow in the React vendor hub:
- Create and edit products with image upload
- Product status auto-updates to `live` via the publish-product Edge Function
- Category browser in the consumer Flutter app reflects changes with no manual refresh

The end-to-end test: **"no account → live product in Flutter app" in one continuous flow, zero developer intervention.**

---

## Screens to Build (React vendor hub)

| Screen | Route | Purpose |
|---|---|---|
| Dashboard | `/dashboard` | Summary stats + recent products list |
| Product List | `/dashboard/products` | Paginated list of all vendor products with status chips |
| Product Create | `/dashboard/products/new` | Full product creation form |
| Product Edit | `/dashboard/products/:id/edit` | Same form, pre-populated |
| Category Manager | `/dashboard/categories` | Read-only view of live categories (vendor can't create categories) |

---

## How We Will Implement It

### Step 1 — Dashboard shell

File: `vendor-hub-web/src/features/dashboard/DashboardLayout.tsx`

Sidebar nav with:
- Blinkit yellow accent bar
- Links: Dashboard / Products / Categories / Settings (stub)
- Vendor business name + approval status badge at top
- Logout button at bottom

### Step 2 — Product list page

File: `vendor-hub-web/src/features/catalog/ProductListPage.tsx`

```typescript
// Fetch vendor's products with Realtime subscription for live status updates
const [products, setProducts] = useState<Product[]>([]);

useEffect(() => {
  // Initial fetch
  supabase
    .from('products')
    .select('*, product_images(webp_url, is_primary)')
    .order('created_at', { ascending: false })
    .then(({ data }) => setProducts(data ?? []));

  // Realtime: watch own products for status changes
  const channel = supabase
    .channel('vendor-products')
    .on('postgres_changes', {
      event: '*',
      schema: 'public',
      table: 'products',
    }, (payload) => {
      setProducts(prev => {
        if (payload.eventType === 'INSERT') return [payload.new as Product, ...prev];
        if (payload.eventType === 'UPDATE') return prev.map(p => p.id === payload.new.id ? payload.new as Product : p);
        return prev;
      });
    })
    .subscribe();

  return () => supabase.removeChannel(channel);
}, []);
```

UI: Table with columns: Image thumbnail, Name, Category, MRP, Selling Price, Status chip (color-coded), Actions (Edit / Delete).

Status chip colors:
- `draft` → gray
- `pending_review` → amber (animated pulse to show it's processing)
- `live` → green
- `rejected` → red + tooltip showing rejection reason from audit log

### Step 3 — Product create/edit form

File: `vendor-hub-web/src/features/catalog/ProductFormPage.tsx`

Fields:
```typescript
interface ProductFormData {
  name: string;           // required
  categoryId: string;     // required — dropdown from live categories
  mrp: number;            // required, > 0
  sellingPrice: number;   // required, > 0, <= mrp
  unit: string;           // required — text or dropdown ("500g", "1kg", "1L", "Pack of 6", etc.)
  stockQty: number;       // required, >= 0
  images: File[];         // 1–6 images, required at least 1
}
```

#### Image upload flow (critical — implement in this exact order):

```typescript
async function uploadImages(files: File[], vendorId: string, productId: string) {
  const urls: string[] = [];

  for (const file of files) {
    // 1. Compress to WebP (browser-image-compression)
    const compressed = await compressToWebP(file);

    // 2. Upload to Supabase Storage with vendor-scoped path
    const path = `${vendorId}/${productId}/${crypto.randomUUID()}.webp`;
    const { error } = await supabase.storage
      .from('product-images')
      .upload(path, compressed, { contentType: 'image/webp', upsert: false });

    if (error) throw error;

    // 3. Get public URL
    const { data } = supabase.storage.from('product-images').getPublicUrl(path);
    urls.push(data.publicUrl);
  }

  return urls;
}
```

Show per-image upload progress with a progress bar (use `onUploadProgress` from Supabase storage upload).

#### Form submit flow:

```typescript
async function handleSubmit(data: ProductFormData) {
  // 1. Insert product (status = 'pending_review' is set by DB Webhook trigger)
  const { data: product } = await supabase
    .from('products')
    .insert({
      name: data.name,
      category_id: data.categoryId,
      mrp: data.mrp,
      selling_price: data.sellingPrice,
      unit: data.unit,
      stock_qty: data.stockQty,
      vendor_id: vendorId,
      status: 'pending_review',   // explicit — triggers the DB Webhook
    })
    .select()
    .single();

  // 2. Upload images (after product ID is known)
  const urls = await uploadImages(data.images, vendorId, product.id);

  // 3. Insert product_images rows
  await supabase.from('product_images').insert(
    urls.map((url, i) => ({
      product_id: product.id,
      webp_url: url,
      sort_order: i,
      is_primary: i === 0,
    }))
  );

  // 4. Trigger DB Webhook by updating to pending_review
  // (already pending_review from insert — webhook fires on INSERT too)

  // 5. Redirect to product list — status chip will animate pending → live via Realtime
  navigate('/dashboard/products');
}
```

#### Edit mode:
- Pre-populate all fields from existing product data
- Show existing images with delete option (removes from Storage + `product_images` row)
- On save: `UPDATE products SET ... status = 'pending_review'` → re-triggers the webhook

### Step 4 — Category dropdown (read-only from Supabase)

File: `vendor-hub-web/src/features/categories/useCategoriesQuery.ts`
```typescript
export function useCategoriesQuery() {
  return useQuery({
    queryKey: ['categories'],
    queryFn: async () => {
      const { data } = await supabase
        .from('categories')
        .select('*')
        .eq('is_active', true)
        .order('sort_order');
      return data ?? [];
    },
    staleTime: 5 * 60 * 1000,   // cache 5 minutes
  });
}
```

### Step 5 — Validation (client-side, mirrors Edge Function rules)

```typescript
const productSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  categoryId: z.string().uuid('Select a category'),
  mrp: z.number().positive('MRP must be greater than 0'),
  sellingPrice: z.number().positive(),
  unit: z.string().min(1),
  stockQty: z.number().int().min(0),
}).refine(data => data.sellingPrice <= data.mrp, {
  message: 'Selling price cannot exceed MRP',
  path: ['sellingPrice'],
});
```

Use `react-hook-form` + `zod` for form state.

---

## Files in Scope

```
vendor-hub-web/src/
├── features/
│   ├── dashboard/
│   │   ├── DashboardLayout.tsx             [CREATE]
│   │   └── DashboardHomePage.tsx           [CREATE]
│   ├── catalog/
│   │   ├── ProductListPage.tsx             [CREATE]
│   │   ├── ProductFormPage.tsx             [CREATE]
│   │   └── hooks/
│   │       ├── useProductsQuery.ts         [CREATE]
│   │       └── useProductMutation.ts       [CREATE]
│   └── categories/
│       └── useCategoriesQuery.ts           [CREATE]
├── components/
│   ├── StatusChip.tsx                      [CREATE]
│   └── ImageUploader.tsx                   [CREATE]
└── app/router.tsx                          [MODIFY — add dashboard routes]
```

**Additional dependencies to install:**
```bash
npm install react-hook-form @hookform/resolvers zod @tanstack/react-query
```

**Out of scope:** admin approval flow, inventory per dark store, Flutter changes (consumer app already reflects changes via Realtime from Phase 3).

---

## Acceptance Criteria

- [ ] Vendor can create a product with 1–6 images (compressed to WebP) and submit
- [ ] Product appears in `/dashboard/products` with status `pending_review` (amber pulse)
- [ ] Status chip auto-updates to `live` (green) within 1–2 seconds via Realtime (no page refresh)
- [ ] Same product appears in Flutter consumer app's product listing within 1–2 seconds
- [ ] Product with no images → Edge Function returns `rejected` → red chip with rejection reason visible
- [ ] Edit flow: updating a product re-triggers validation → status cycles back through `pending_review → live`
- [ ] Image upload respects path: `{vendor_id}/{product_id}/...`
- [ ] A second vendor cannot access the first vendor's products (RLS check)
- [ ] `product_audit_log` has entries for every status change
- [ ] Form validation prevents: empty name, MRP = 0, selling_price > MRP

---

## Security Checklist

| # | Control | Action |
|---|---|---|
| 1 | RLS | Cross-vendor product isolation test |
| 6 | Storage path-scoped | Verify upload path is `{vendor_id}/...` |
| 7 | Service-role key | Confirm absent from all vendor hub env vars |
| 9 | Audit log | Every product publish has a log entry |

---

## Next Phase

→ **Phase 6**: Performance layer — Hive cache tuning, WebP validation, pooler config, checkout prefetch (`docs/specs/phase-6-performance-layer.md`)
