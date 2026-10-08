import { assertEquals, assertRejects } from "jsr:@std/assert@1";
import { type DeleteAccountDeps, handleDeleteAccount } from "./handler.ts";

const ME = "a0000000-0000-4000-8000-000000000001";

function fakeDeps(calls: string[], opts: { user?: string | null; failFiles?: boolean } = {}): DeleteAccountDeps {
  return {
    authenticate: () => Promise.resolve(opts.user === null ? null : { userId: opts.user ?? ME }),
    listOwnedGardens: () => Promise.resolve(["solo", "shared"]),
    listMembers: (gardenId) =>
      Promise.resolve(
        gardenId === "solo"
          ? [{ userId: ME, role: "owner", createdAt: "2026-01-01T00:00:00Z" }]
          : [
            { userId: ME, role: "owner", createdAt: "2026-01-01T00:00:00Z" },
            { userId: "viewer", role: "viewer", createdAt: "2026-01-02T00:00:00Z" },
            { userId: "editor", role: "editor", createdAt: "2026-01-03T00:00:00Z" },
          ],
      ),
    transferOwnership: (g, from, to) => {
      calls.push(`transfer:${g}:${from}->${to}`);
      return Promise.resolve();
    },
    deleteGardenFiles: (g) => {
      if (opts.failFiles) return Promise.reject(new Error("storage down"));
      calls.push(`files:${g}`);
      return Promise.resolve(4);
    },
    deleteGarden: (g) => {
      calls.push(`garden:${g}`);
      return Promise.resolve();
    },
    deleteUserRows: (u) => {
      calls.push(`rows:${u}`);
      return Promise.resolve();
    },
    deleteAuthUser: (u) => {
      calls.push(`auth:${u}`);
      return Promise.resolve();
    },
    log: () => {},
  };
}

const post = () => new Request("http://localhost/delete-account", { method: "POST", headers: { Authorization: "Bearer t" } });

Deno.test("transfers shared gardens, deletes solo gardens with files, then the account", async () => {
  const calls: string[] = [];
  const res = await handleDeleteAccount(post(), fakeDeps(calls));
  assertEquals(res.status, 200);
  assertEquals(await res.json(), { deleted: true });
  assertEquals(calls, [
    "files:solo",
    "garden:solo",
    `transfer:shared:${ME}->editor`,
    `rows:${ME}`,
    `auth:${ME}`,
  ]);
});

Deno.test("401 without a user, 405 on GET", async () => {
  const calls: string[] = [];
  assertEquals((await handleDeleteAccount(post(), fakeDeps(calls, { user: null }))).status, 401);
  assertEquals(
    (await handleDeleteAccount(new Request("http://localhost/", { method: "GET" }), fakeDeps(calls))).status,
    405,
  );
  assertEquals(calls, []);
});

Deno.test("storage failure stops before deleting the garden or the account", async () => {
  const calls: string[] = [];
  await assertRejects(() => handleDeleteAccount(post(), fakeDeps(calls, { failFiles: true })));
  assertEquals(calls, []);
});
