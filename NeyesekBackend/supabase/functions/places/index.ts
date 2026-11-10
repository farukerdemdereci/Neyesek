import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get("Authorization")

    if (!authHeader) {
      return json({ error: "Unauthorized" }, 401)
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    )

    const token = authHeader.replace("Bearer ", "")

    const {
      data: { user },
      error: userError
    } = await supabase.auth.getUser(token)

    if (userError || !user) {
      return json({ error: "Invalid user", detail: userError?.message }, 401)
    }

    const url = new URL(req.url)

    const lat = url.searchParams.get("lat")
    const lng = url.searchParams.get("lng")

    if (!lat || !lng) {
      return json({ error: "Missing lat/lng" }, 400)
    }

    const latNumber = Number(lat)
    const lngNumber = Number(lng)

    if (
      !Number.isFinite(latNumber) ||
      latNumber < -90 ||
      latNumber > 90 ||
      !Number.isFinite(lngNumber) ||
      lngNumber < -180 ||
      lngNumber > 180
    ) {
      return json({ error: "Invalid lat/lng" }, 400)
    }

    const radiusParam = Number(url.searchParams.get("radius") ?? "600")

    const safeRadius = Number.isFinite(radiusParam)
      ? Math.min(Math.max(radiusParam, 100), 2000).toString()
      : "600"

    const rawType = url.searchParams.get("type")
    const allowedTypes = ["restaurant", "cafe", "bar"]

    const type =
      rawType && allowedTypes.includes(rawType)
        ? rawType
        : null

    const keyword = (url.searchParams.get("keyword") ?? "").slice(0, 80)

    const priceParam = Number(url.searchParams.get("maxprice"))

    const safePrice =
      Number.isFinite(priceParam) &&
      priceParam >= 1 &&
      priceParam <= 4
        ? Math.floor(priceParam).toString()
        : null

    const ip =
      req.headers
        .get("x-forwarded-for")
        ?.split(",")[0]
        ?.trim() ?? "unknown"

    const startOfDay = new Date()
    startOfDay.setHours(0, 0, 0, 0)

    const startOfMonth = new Date()
    startOfMonth.setDate(1)
    startOfMonth.setHours(0, 0, 0, 0)

    const { data: userLogs, error: userLogError } =
      await supabase
        .from("place_request_logs")
        .select("id")
        .eq("user_id", user.id)
        .gte("created_at", startOfDay.toISOString())

    if (userLogError) {
      return json({ error: "User log read failed", detail: userLogError.message }, 500)
    }

    if ((userLogs?.length ?? 0) >= 20) {
      return json({ error: "Daily limit reached" }, 429)
    }

    const { data: ipLogs, error: ipLogError } =
      await supabase
        .from("place_request_logs")
        .select("id")
        .eq("ip_address", ip)
        .gte("created_at", startOfDay.toISOString())

    if (ipLogError) {
      return json({ error: "IP log read failed", detail: ipLogError.message }, 500)
    }

    if ((ipLogs?.length ?? 0) >= 50) {
      return json({ error: "IP daily limit reached" }, 429)
    }

    const { data: globalLogs, error: globalLogError } =
      await supabase
        .from("place_request_logs")
        .select("id")
        .gte("created_at", startOfMonth.toISOString())

    if (globalLogError) {
      return json({ error: "Global log read failed", detail: globalLogError.message }, 500)
    }

    if ((globalLogs?.length ?? 0) >= 500) {
      return json({ error: "Monthly global limit reached" }, 429)
    }

    const googleKey = Deno.env.get("GOOGLE_API_KEY")

    if (!googleKey) {
      return json({ error: "Google key missing" }, 500)
    }

    const googleUrl = new URL(
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    )

    googleUrl.searchParams.set("location", `${latNumber},${lngNumber}`)
    googleUrl.searchParams.set("radius", safeRadius)
    googleUrl.searchParams.set("key", googleKey)

    if (type) {
      googleUrl.searchParams.set("type", type)
    }

    if (keyword) {
      googleUrl.searchParams.set("keyword", keyword)
    }

    if (safePrice) {
      googleUrl.searchParams.set("maxprice", safePrice)
    }

    console.log("GOOGLE URL:", googleUrl.toString())

    const googleResponse = await fetch(googleUrl)
    const data = await googleResponse.json()

    if (googleResponse.ok && data.status === "OK") {
      const { error: insertError } =
        await supabase
          .from("place_request_logs")
          .insert({
            user_id: user.id,
            ip_address: ip
          })

      if (insertError) {
        return json({ error: "Log insert failed", detail: insertError.message }, 500)
      }
    }

    return json(data, googleResponse.status)

  } catch (e) {
    return json(
      {
        error: "Unexpected error",
        detail: String(e)
      },
      500
    )
  }
})

function json(data: unknown, status = 200) {
  return new Response(
    JSON.stringify(data),
    {
      status,
      headers: {
        "Content-Type": "application/json"
      }
    }
  )
}