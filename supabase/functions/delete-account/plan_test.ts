import { assertEquals } from "jsr:@std/assert@1";
import { pickNewOwner, planGardens } from "./plan.ts";

const ME = "u-me";

Deno.test("longest-standing editor becomes the owner", () => {
  assertEquals(
    pickNewOwner([
      { userId: ME, role: "owner", createdAt: "2026-01-01T00:00:00Z" },
      { userId: "viewer-old", role: "viewer", createdAt: "2026-01-02T00:00:00Z" },
      { userId: "editor-new", role: "editor", createdAt: "2026-03-01T00:00:00Z" },
      { userId: "editor-old", role: "editor", createdAt: "2026-02-01T00:00:00Z" },
    ], ME),
    "editor-old",
  );
});

Deno.test("without editors any member (longest-standing) becomes the owner", () => {
  assertEquals(
    pickNewOwner([
      { userId: ME, role: "owner", createdAt: "2026-01-01T00:00:00Z" },
      { userId: "viewer-new", role: "viewer", createdAt: "2026-05-01T00:00:00Z" },
      { userId: "viewer-old", role: "viewer", createdAt: "2026-04-01T00:00:00Z" },
    ], ME),
    "viewer-old",
  );
});

Deno.test("no other member means the garden is deleted", () => {
  assertEquals(pickNewOwner([{ userId: ME, role: "owner", createdAt: "2026-01-01T00:00:00Z" }], ME), null);
  assertEquals(
    planGardens([
      { gardenId: "g1", members: [{ userId: ME, role: "owner", createdAt: "2026-01-01T00:00:00Z" }] },
      {
        gardenId: "g2",
        members: [
          { userId: ME, role: "owner", createdAt: "2026-01-01T00:00:00Z" },
          { userId: "e", role: "editor", createdAt: "2026-01-02T00:00:00Z" },
        ],
      },
    ], ME),
    [{ gardenId: "g1", action: "delete" }, { gardenId: "g2", action: "transfer", newOwnerId: "e" }],
  );
});
