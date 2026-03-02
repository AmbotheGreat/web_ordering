// import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
// import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// serve(async (req) => {
//     try {
//         const { barcode, branch_id } = await req.json();

//         if (!barcode || !branch_id) {
//             return new Response(
//                 JSON.stringify({ error: "barcode and branch_id are required" }),
//                 { status: 400 }
//             );
//         }

//         const supabase = createClient(
//             Deno.env.get("SUPABASE_URL")!,
//             Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
//         );

//         // 1️⃣ Fetch assignments
//         const { data: assignments, error: assignError } = await supabase
//             .from("product_option_group_assignments")
//             .select("group_preset_id, option_group_id, is_override")
//             .eq("barcode", barcode)
//             .eq("branch_id", branch_id);

//         if (assignError || !assignments || assignments.length === 0) {
//             return new Response(JSON.stringify({ barcode, option_groups: [] }), {
//                 headers: { "Content-Type": "application/json" },
//             });
//         }

//         // 2️⃣ Resolve Group IDs
//         const hasOverride = assignments.some((a) => a.is_override);
//         let optionGroupIds: number[] = [];

//         if (hasOverride) {
//             optionGroupIds = assignments
//                 .filter((a) => a.option_group_id)
//                 .map((a) => a.option_group_id!);
//         } else {
//             const presetIds = assignments
//                 .filter((a) => a.group_preset_id)
//                 .map((a) => a.group_preset_id!);

//             if (presetIds.length > 0) {
//                 const { data: presetGroups } = await supabase
//                     .from("option_group_preset_groups")
//                     .select("option_group_id")
//                     .in("group_preset_id", presetIds)
//                     .eq("branch_id", branch_id);

//                 optionGroupIds = presetGroups?.map((p) => p.option_group_id) || [];
//             }
//         }

//         if (optionGroupIds.length === 0) {
//             return new Response(JSON.stringify({ barcode, option_groups: [] }), {
//                 headers: { "Content-Type": "application/json" },
//             });
//         }

//         // 3️⃣ Fetch Option Groups
//         const { data: optionGroups } = await supabase
//             .from("option_groups")
//             .select("id, name, is_required, selection_type, max_select, value_preset_id")
//             .in("id", optionGroupIds)
//             .eq("branch_id", branch_id);

//         if (!optionGroups || optionGroups.length === 0) {
//             return new Response(JSON.stringify({ barcode, option_groups: [] }), {
//                 headers: { "Content-Type": "application/json" },
//             });
//         }

//         // 4️⃣ Fetch Option Values (Raw)
//         const presetIdsForValues = optionGroups.map(g => g.value_preset_id).filter(Boolean);

//         // We fetch the basic value data first
//         const { data: allOptionValues, error: valueError } = await supabase
//             .from("option_values")
//             .select(`
//         id,
//         option_group_id,
//         value_preset_id,
//         alias,
//         should_use_alias,
//         barcode,
//         price_delta,
//         local_id,
//         display_order
//       `)
//             .or(`option_group_id.in.(${optionGroupIds.join(",")}),value_preset_id.in.(${presetIdsForValues.length > 0 ? presetIdsForValues.join(",") : -1})`)
//             .eq("branch_id", branch_id)
//             .order("display_order");

//         if (valueError) throw valueError;

//         // 5️⃣ Fetch Item Names (The "Manual Join")
//         // Extract unique barcodes from the fetched options
//         const uniqueBarcodes = [...new Set(allOptionValues?.map(v => v.barcode) || [])];

//         let itemMap = new Map<string, string>();

//         if (uniqueBarcodes.length > 0) {
//             const { data: items, error: itemsError } = await supabase
//                 .from("items")
//                 .select("barcode, item_name")
//                 .in("barcode", uniqueBarcodes)
//                 .eq("branch_id", branch_id); // Crucial: Items are unique by branch + barcode

//             if (!itemsError && items) {
//                 // Create a lookup map: Barcode -> Item Name
//                 items.forEach(item => itemMap.set(item.barcode, item.item_name));
//             }
//         }

//         // 6️⃣ Assemble Response
//         const result = optionGroups.map((group) => {
//             const groupOptions = (allOptionValues || []).filter((v) => {
//                 if (group.value_preset_id && v.value_preset_id == group.value_preset_id) return true;
//                 return v.option_group_id == group.id;
//             });

//             return {
//                 id: group.id,
//                 name: group.name,
//                 is_required: group.is_required,
//                 selection_type: group.selection_type,
//                 max_select: group.max_select,
//                 options: groupOptions.map((v) => {
//                     // Look up the name from our manual map
//                     const fetchedItemName = itemMap.get(v.barcode);
//                     const fallbackName = "Unknown Item";
//                     const finalName = fetchedItemName || fallbackName;

//                     return {
//                         id: v.id,
//                         local_id: v.local_id,
//                         name: finalName,
//                         label: v.should_use_alias ? (v.alias || finalName) : finalName,
//                         barcode: v.barcode,
//                         price_delta: v.price_delta,
//                     };
//                 }),
//             };
//         });

//         return new Response(JSON.stringify({ barcode, option_groups: result }), {
//             headers: { "Content-Type": "application/json" },
//         });

//     } catch (err) {
//         console.error("Function Error:", err);
//         return new Response(JSON.stringify({ error: "Server error", details: err.message }), {
//             status: 500,
//             headers: { "Content-Type": "application/json" }
//         });
//     }
// });