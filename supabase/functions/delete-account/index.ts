// Edge Function delete-account: smazání účtu a dat (spec kap. 9, GDPR čl. 17).
// POST, vyžaduje přihlášení; maže účet volajícího uživatele.

import { json } from "../_shared/http.ts";
import { authenticateRequest, createServiceClient } from "../_shared/supabase.ts";
import { handleDeleteAccount } from "./handler.ts";

const BUCKET = "photos";
const PAGE = 1000;

Deno.serve(async (req) => {
  try {
    const db = createServiceClient();

    return await handleDeleteAccount(req, {
      authenticate: authenticateRequest,

      async listOwnedGardens(userId) {
        const { data, error } = await db.from("gardens").select("id").eq("owner_id", userId);
        if (error) throw error;
        return (data ?? []).map((g: { id: string }) => g.id);
      },

      async listMembers(gardenId) {
        const { data, error } = await db
          .from("garden_members")
          .select("user_id, role, created_at")
          .eq("garden_id", gardenId);
        if (error) throw error;
        return (data ?? []).map((m: { user_id: string; role: string; created_at: string }) => ({
          userId: m.user_id,
          role: m.role,
          createdAt: m.created_at,
        }));
      },

      async transferOwnership(gardenId, fromUserId, toUserId) {
        const { error } = await db.rpc("transfer_garden_ownership", {
          p_garden_id: gardenId,
          p_from_user: fromUserId,
          p_to_user: toUserId,
        });
        if (error) throw error;
      },

      async deleteGardenFiles(gardenId) {
        // Soubory jsou ploše v '<gardenId>/'; mažeme po stránkách, dokud něco zbývá.
        let total = 0;
        for (let round = 0; round < 1000; round++) {
          const { data, error } = await db.storage.from(BUCKET).list(gardenId, { limit: PAGE, offset: 0 });
          if (error) throw error;
          const paths = (data ?? [])
            .filter((f: { name: string; id: string | null }) => f.id !== null)
            .map((f: { name: string }) => `${gardenId}/${f.name}`);
          if (paths.length === 0) break;
          const { data: removed, error: removeError } = await db.storage.from(BUCKET).remove(paths);
          if (removeError) throw removeError;
          if (!removed || removed.length === 0) throw new Error("storage_remove_failed");
          total += removed.length;
        }
        return total;
      },

      async deleteGarden(gardenId) {
        const { error } = await db.from("gardens").delete().eq("id", gardenId);
        if (error) throw error;
      },

      async deleteUserRows(userId) {
        // Pořadí: děti před rodiči. Zbytek by smazala i kaskáda z auth.users.
        const steps: Array<[string, string]> = [
          ["assistant_messages", "user_id"],
          ["assistant_threads", "user_id"],
          ["assistant_usage", "user_id"],
          ["entitlements", "user_id"],
          ["garden_members", "user_id"],
          ["profiles", "id"],
        ];
        for (const [table, column] of steps) {
          const { error } = await db.from(table).delete().eq(column, userId);
          if (error) throw error;
        }
      },

      async deleteAuthUser(userId) {
        const { error } = await db.auth.admin.deleteUser(userId);
        if (error) throw error;
      },

      log: (entry) => console.log(JSON.stringify(entry)),
    });
  } catch (e) {
    console.error(JSON.stringify({ event: "delete_account_error", error: (e as Error)?.message ?? "unknown" }));
    return json(500, { error: "internal" });
  }
});
