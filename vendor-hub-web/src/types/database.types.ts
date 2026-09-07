export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      addresses: {
        Row: {
          city: string
          geo_lat: number | null
          geo_lng: number | null
          id: string
          is_default: boolean
          label: string | null
          line1: string
          line2: string | null
          pincode: string
          user_id: string
        }
        Insert: {
          city: string
          geo_lat?: number | null
          geo_lng?: number | null
          id?: string
          is_default?: boolean
          label?: string | null
          line1: string
          line2?: string | null
          pincode: string
          user_id: string
        }
        Update: {
          city?: string
          geo_lat?: number | null
          geo_lng?: number | null
          id?: string
          is_default?: boolean
          label?: string | null
          line1?: string
          line2?: string | null
          pincode?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "addresses_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      cart_items: {
        Row: {
          cart_id: string
          id: string
          product_id: string
          qty: number
        }
        Insert: {
          cart_id: string
          id?: string
          product_id: string
          qty?: number
        }
        Update: {
          cart_id?: string
          id?: string
          product_id?: string
          qty?: number
        }
        Relationships: [
          {
            foreignKeyName: "cart_items_cart_id_fkey"
            columns: ["cart_id"]
            isOneToOne: false
            referencedRelation: "carts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "cart_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      carts: {
        Row: {
          id: string
          user_id: string
        }
        Insert: {
          id?: string
          user_id: string
        }
        Update: {
          id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "carts_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      categories: {
        Row: {
          id: string
          image_url: string | null
          is_active: boolean
          more_count: number
          name: string
          parent_id: string | null
          section_type: string
          slug: string
          sort_order: number
        }
        Insert: {
          id?: string
          image_url?: string | null
          is_active?: boolean
          more_count?: number
          name: string
          parent_id?: string | null
          section_type?: string
          slug: string
          sort_order?: number
        }
        Update: {
          id?: string
          image_url?: string | null
          is_active?: boolean
          more_count?: number
          name?: string
          parent_id?: string | null
          section_type?: string
          slug?: string
          sort_order?: number
        }
        Relationships: [
          {
            foreignKeyName: "categories_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
        ]
      }
      dev_payments: {
        Row: {
          cart_order_id: string | null
          created_at: string
          id: string
          order_id: string
          paid_at: string | null
          payable_amount: number
          provider: string
          requested_amount: number
          sender_name: string | null
          status: string
          upi_vpa: string
          user_id: string | null
          utr: string | null
        }
        Insert: {
          cart_order_id?: string | null
          created_at?: string
          id?: string
          order_id: string
          paid_at?: string | null
          payable_amount: number
          provider?: string
          requested_amount: number
          sender_name?: string | null
          status?: string
          upi_vpa: string
          user_id?: string | null
          utr?: string | null
        }
        Update: {
          cart_order_id?: string | null
          created_at?: string
          id?: string
          order_id?: string
          paid_at?: string | null
          payable_amount?: number
          provider?: string
          requested_amount?: number
          sender_name?: string | null
          status?: string
          upi_vpa?: string
          user_id?: string | null
          utr?: string | null
        }
        Relationships: []
      }
      device_tokens: {
        Row: {
          id: string
          platform: string
          token: string
          updated_at: string
          user_id: string | null
        }
        Insert: {
          id?: string
          platform: string
          token: string
          updated_at?: string
          user_id?: string | null
        }
        Update: {
          id?: string
          platform?: string
          token?: string
          updated_at?: string
          user_id?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "device_tokens_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      order_items: {
        Row: {
          id: string
          order_id: string
          price_at_purchase: number
          product_id: string
          qty: number
        }
        Insert: {
          id?: string
          order_id: string
          price_at_purchase: number
          product_id: string
          qty: number
        }
        Update: {
          id?: string
          order_id?: string
          price_at_purchase?: number
          product_id?: string
          qty?: number
        }
        Relationships: [
          {
            foreignKeyName: "order_items_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_items_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      orders: {
        Row: {
          address_id: string
          id: string
          placed_at: string
          status: string
          total_amount: number
          updated_at: string
          user_id: string
        }
        Insert: {
          address_id: string
          id?: string
          placed_at?: string
          status?: string
          total_amount: number
          updated_at?: string
          user_id: string
        }
        Update: {
          address_id?: string
          id?: string
          placed_at?: string
          status?: string
          total_amount?: number
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "orders_address_id_fkey"
            columns: ["address_id"]
            isOneToOne: false
            referencedRelation: "addresses"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
        ]
      }
      payments: {
        Row: {
          amount: number
          created_at: string
          id: string
          order_id: string
          razorpay_order_id: string | null
          razorpay_payment_id: string | null
          status: string
        }
        Insert: {
          amount: number
          created_at?: string
          id?: string
          order_id: string
          razorpay_order_id?: string | null
          razorpay_payment_id?: string | null
          status?: string
        }
        Update: {
          amount?: number
          created_at?: string
          id?: string
          order_id?: string
          razorpay_order_id?: string | null
          razorpay_payment_id?: string | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "payments_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: true
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      product_audit_log: {
        Row: {
          action: string
          changed_by: string | null
          created_at: string
          diff: Json | null
          id: string
          product_id: string
        }
        Insert: {
          action: string
          changed_by?: string | null
          created_at?: string
          diff?: Json | null
          id?: string
          product_id: string
        }
        Update: {
          action?: string
          changed_by?: string | null
          created_at?: string
          diff?: Json | null
          id?: string
          product_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_audit_log_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      product_images: {
        Row: {
          id: string
          is_primary: boolean
          product_id: string
          sort_order: number
          webp_url: string
        }
        Insert: {
          id?: string
          is_primary?: boolean
          product_id: string
          sort_order?: number
          webp_url: string
        }
        Update: {
          id?: string
          is_primary?: boolean
          product_id?: string
          sort_order?: number
          webp_url?: string
        }
        Relationships: [
          {
            foreignKeyName: "product_images_product_id_fkey"
            columns: ["product_id"]
            isOneToOne: false
            referencedRelation: "products"
            referencedColumns: ["id"]
          },
        ]
      }
      products: {
        Row: {
          category_id: string
          created_at: string
          id: string
          mrp: number
          name: string
          selling_price: number
          status: string
          stock_qty: number
          unit: string
          updated_at: string
          vendor_id: string
        }
        Insert: {
          category_id: string
          created_at?: string
          id?: string
          mrp: number
          name: string
          selling_price: number
          status?: string
          stock_qty?: number
          unit: string
          updated_at?: string
          vendor_id: string
        }
        Update: {
          category_id?: string
          created_at?: string
          id?: string
          mrp?: number
          name?: string
          selling_price?: number
          status?: string
          stock_qty?: number
          unit?: string
          updated_at?: string
          vendor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "products_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "products_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
            referencedColumns: ["id"]
          },
        ]
      }
      users: {
        Row: {
          auth_user_id: string
          created_at: string
          id: string
          name: string | null
          phone: string
        }
        Insert: {
          auth_user_id: string
          created_at?: string
          id?: string
          name?: string | null
          phone: string
        }
        Update: {
          auth_user_id?: string
          created_at?: string
          id?: string
          name?: string | null
          phone?: string
        }
        Relationships: []
      }
      vendor_users: {
        Row: {
          auth_user_id: string
          id: string
          phone_number: string | null
          phone_verified: boolean
          role: string
          vendor_id: string
        }
        Insert: {
          auth_user_id: string
          id?: string
          phone_number?: string | null
          phone_verified?: boolean
          role?: string
          vendor_id: string
        }
        Update: {
          auth_user_id?: string
          id?: string
          phone_number?: string | null
          phone_verified?: boolean
          role?: string
          vendor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "vendor_users_vendor_id_fkey"
            columns: ["vendor_id"]
            isOneToOne: false
            referencedRelation: "vendors"
            referencedColumns: ["id"]
          },
        ]
      }
      vendors: {
        Row: {
          business_name: string
          categories: Json | null
          contact_name: string | null
          created_at: string
          designation: string | null
          gstin: string | null
          id: string
          onboarding_status: string
          spoc_name: string | null
          status: string
        }
        Insert: {
          business_name: string
          categories?: Json | null
          contact_name?: string | null
          created_at?: string
          designation?: string | null
          gstin?: string | null
          id?: string
          onboarding_status?: string
          spoc_name?: string | null
          status?: string
        }
        Update: {
          business_name?: string
          categories?: Json | null
          contact_name?: string | null
          created_at?: string
          designation?: string | null
          gstin?: string | null
          id?: string
          onboarding_status?: string
          spoc_name?: string | null
          status?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      show_limit: { Args: never; Returns: number }
      show_trgm: { Args: { "": string }; Returns: string[] }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never
