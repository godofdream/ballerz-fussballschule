interface Env {
  DB: D1Database;
  BREVO_API_KEY: string;
  BREVO_SENDER_EMAIL?: string;
  BREVO_SENDER_NAME?: string;
  ADMIN_EMAIL?: string;
}

export const onRequestPost: PagesFunction<Env> = async (context) => {
  const { request, env } = context;
  const form = await request.formData();
  const name = String(form.get("name") || "").trim();
  const email = String(form.get("email") || "").trim();
  const phone = String(form.get("phone") || "").trim();
  const message = String(form.get("message") || "").trim();

  if (!name || !email || !message) {
    return new Response("Missing fields", { status: 400 });
  }

  await env.DB.prepare(
    "INSERT INTO contact_messages (name, email, phone, message) VALUES (?, ?, ?, ?)"
  )
    .bind(name, email, phone || null, message)
    .run();

  if (env.BREVO_API_KEY) {
    const admin = env.ADMIN_EMAIL || env.BREVO_SENDER_EMAIL || "info@ballerz-fussballschule.de";
    const senderEmail = env.BREVO_SENDER_EMAIL || admin;
    await fetch("https://api.brevo.com/v3/smtp/email", {
      method: "POST",
      headers: {
        "api-key": env.BREVO_API_KEY,
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: JSON.stringify({
        sender: { name: env.BREVO_SENDER_NAME || "Ballerz Website", email: senderEmail },
        to: [{ email: admin }],
        replyTo: { email, name },
        subject: `Kontaktformular: ${name}`,
        htmlContent: `<p><strong>Name:</strong> ${name}</p><p><strong>E-Mail:</strong> ${email}</p><p>${message}</p>`,
      }),
    });
  }

  return Response.redirect(new URL("/success", request.url).toString(), 303);
};
