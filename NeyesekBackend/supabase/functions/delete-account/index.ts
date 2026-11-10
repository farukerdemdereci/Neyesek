import { createClient } from "npm:@supabase/supabase-js@2"

Deno.serve(async (req) => {
  const authHeader = req.headers.get("Authorization")

  if (!authHeader) {
    return new Response("Unauthorized", { status: 401 })
  }

  // 1) Kullanıcıyı doğrulamak için user client
  const userClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    {
      global: {
        headers: {
          Authorization: authHeader
        }
      }
    }
  )

  const {
    data: { user },
    error: userError
  } = await userClient.auth.getUser()

  if (userError || !user) {
    return new Response("User not found", { status: 401 })
  }

  // 2) Silmek için service role admin client
  const adminClient = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
  )

  await adminClient
    .from("places")
    .delete()
    .eq("user_id", user.id)

  const { error: deleteError } =
    await adminClient.auth.admin.deleteUser(user.id)

  if (deleteError) {
    return new Response(deleteError.message, { status: 500 })
  }

  return new Response(
    JSON.stringify({ success: true }),
    {
      status: 200,
      headers: {
        "Content-Type": "application/json"
      }
    }
  )
})