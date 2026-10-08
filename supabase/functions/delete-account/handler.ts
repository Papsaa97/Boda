// HTTP logika smazání účtu (spec kap. 9). Závislosti zvenku kvůli testům.

import { json, preflight } from "../_shared/http.ts";
import { type Member, planGardens } from "./plan.ts";

export interface DeleteAccountDeps {
  authenticate(req: Request): Promise<{ userId: string } | null>;
  listOwnedGardens(userId: string): Promise<string[]>;
  listMembers(gardenId: string): Promise<Member[]>;
  transferOwnership(gardenId: string, fromUserId: string, toUserId: string): Promise<void>;
  /** Smaže všechny soubory pod '<gardenId>/' v bucketu photos; vrací počet. */
  deleteGardenFiles(gardenId: string): Promise<number>;
  /** Smaže zahradu (data zahrady se smažou kaskádou). */
  deleteGarden(gardenId: string): Promise<void>;
  /** Smaže konverzace s Bóďou, počty dotazů, nárok, členství a profil. */
  deleteUserRows(userId: string): Promise<void>;
  /** Smaže uživatele v Supabase Auth (admin API). */
  deleteAuthUser(userId: string): Promise<void>;
  log(entry: Record<string, unknown>): void;
}

export async function handleDeleteAccount(req: Request, deps: DeleteAccountDeps): Promise<Response> {
  const pre = preflight(req);
  if (pre) return pre;
  if (req.method !== "POST") return json(405, { error: "method_not_allowed" });

  const user = await deps.authenticate(req).catch(() => null);
  if (!user) return json(401, { error: "unauthorized" });

  const owned = await deps.listOwnedGardens(user.userId);
  const gardens = [];
  for (const gardenId of owned) {
    gardens.push({ gardenId, members: await deps.listMembers(gardenId) });
  }
  const steps = planGardens(gardens, user.userId);

  let transferred = 0;
  let deleted = 0;
  let files = 0;
  for (const step of steps) {
    if (step.action === "transfer") {
      await deps.transferOwnership(step.gardenId, user.userId, step.newOwnerId);
      transferred++;
    } else {
      // Nejdřív soubory: když selžou, zahrada zůstane a smazání jde zopakovat.
      files += await deps.deleteGardenFiles(step.gardenId);
      await deps.deleteGarden(step.gardenId);
      deleted++;
    }
  }

  await deps.deleteUserRows(user.userId);
  await deps.deleteAuthUser(user.userId);

  deps.log({
    event: "account_deleted",
    userId: user.userId,
    gardensTransferred: transferred,
    gardensDeleted: deleted,
    filesDeleted: files,
  });
  return json(200, { deleted: true });
}
