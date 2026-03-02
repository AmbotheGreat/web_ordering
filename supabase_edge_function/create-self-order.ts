// import { serve } from 'https://deno.land/std@0.192.0/http/server.ts';
// import { createClient } from 'jsr:@supabase/supabase-js@2';

// // 1. Updated CORS headers to allow all
// const corsHeaders = {
//     'Access-Control-Allow-Origin': '*', // Allows any domain
//     'Access-Control-Allow-Methods': 'POST, OPTIONS',
//     'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-device-id',
// };

// serve(async (req) => {
//     // 2. Handle Preflight requests immediately
//     if (req.method === 'OPTIONS') {
//         return new Response('ok', { headers: corsHeaders });
//     }

//     if (req.method !== 'POST') {
//         return new Response(JSON.stringify({ error: 'Method Not Allowed' }), {
//             status: 405,
//             headers: { ...corsHeaders, 'Content-Type': 'application/json' }
//         });
//     }

//     const supabase = createClient(
//         Deno.env.get('SUPABASE_URL') ?? '',
//         Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
//     );

//     try {
//         const payload = await req.json();
//         const deviceId = req.headers.get('x-device-id') || '';

//         // Validation Logic
//         const requiredFields = ['order_type_id', 'branch_id', 'items'];
//         for (const field of requiredFields) {
//             if (!payload[field]) {
//                 return new Response(JSON.stringify({ error: `Missing field: ${field}` }), {
//                     status: 400,
//                     headers: { ...corsHeaders, 'Content-Type': 'application/json' }
//                 });
//             }
//         }

//         if (!Array.isArray(payload.items) || payload.items.length === 0) {
//             return new Response(JSON.stringify({ error: 'No order items provided' }), {
//                 status: 400,
//                 headers: { ...corsHeaders, 'Content-Type': 'application/json' }
//             });
//         }

//         // Insert order
//         const { data: orderInsert, error: orderError } = await supabase
//             .from('self_orders')
//             .insert({
//                 order_type_id: Number(payload.order_type_id),
//                 order_status: 0,
//                 branch_id: Number(payload.branch_id),
//                 created_at: new Date().toISOString(),
//                 device_id: deviceId,
//                 customer_name: payload.customer_name
//             })
//             .select('id, order_key')
//             .single();

//         if (orderError) throw orderError;

//         const orderId = orderInsert.id;

//         // Prepare and insert items
//         const itemRows = payload.items.map((item) => ({
//             self_order_id: orderId,
//             branch_id: Number(payload.branch_id),
//             item_barcode: String(item.item_barcode),
//             quantity: Number(item.quantity) || 0,
//             item_price: Number(item.item_price) || 0,
//             item_modifiers: item.item_modifiers ? String(item.item_modifiers).slice(0, 255) : null,
//             item_customization: item.item_customization || null
//         }));

//         const { error: itemsError } = await supabase.from('self_order_items').insert(itemRows);
//         if (itemsError) throw itemsError;

//         return new Response(JSON.stringify({
//             message: 'Order and items created successfully',
//             order: { id: orderId, order_key: orderInsert.order_key }
//         }), {
//             status: 201,
//             headers: { ...corsHeaders, 'Content-Type': 'application/json' }
//         });

//     } catch (err) {
//         console.error('Create Order Error:', err);
//         return new Response(JSON.stringify({ error: 'Internal Server Error' }), {
//             status: 500,
//             headers: { ...corsHeaders, 'Content-Type': 'application/json' }
//         });
//     }
// });