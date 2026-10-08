// Čistá logika smazání účtu: komu předat vlastnictví zahrady.

export interface Member {
  userId: string;
  role: "owner" | "editor" | "viewer" | string;
  createdAt: string;
}

/**
 * Nový vlastník zahrady po odchodu dosavadního: nejdéle přítomný editor,
 * jinak nejdéle přítomný jiný člen; null, když nikdo další není
 * (zahrada se pak smaže).
 */
export function pickNewOwner(members: Member[], leavingUserId: string): string | null {
  const others = members
    .filter((m) => m.userId !== leavingUserId)
    .sort((a, b) => {
      const ta = Date.parse(a.createdAt);
      const tb = Date.parse(b.createdAt);
      return (Number.isNaN(ta) ? Infinity : ta) - (Number.isNaN(tb) ? Infinity : tb) ||
        a.userId.localeCompare(b.userId);
    });
  const editor = others.find((m) => m.role === "editor");
  return (editor ?? others[0])?.userId ?? null;
}

export type GardenStep =
  | { gardenId: string; action: "transfer"; newOwnerId: string }
  | { gardenId: string; action: "delete" };

/** Plán pro každou vlastněnou zahradu: předat, nebo smazat. */
export function planGardens(
  gardens: Array<{ gardenId: string; members: Member[] }>,
  leavingUserId: string,
): GardenStep[] {
  return gardens.map(({ gardenId, members }) => {
    const newOwnerId = pickNewOwner(members, leavingUserId);
    return newOwnerId ? { gardenId, action: "transfer", newOwnerId } : { gardenId, action: "delete" };
  });
}
