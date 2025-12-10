import { RENDERER_MODE } from "./environment";

export const play_url =
  process.env.PLAY_URL ??
  (process.env.MAP_STORAGE_PROTOCOL ?? "http") +
    "://play.wocc.com.br";
export const map_storage_url =
  (process.env.MAP_STORAGE_PROTOCOL ?? "http") +
  "://john.doe:password@" +
  (process.env.MAP_STORAGE_ENDPOINT ?? "map-storage.wocc.com.br");
export const maps_domain =
  process.env.MAPS_DOMAIN ?? "maps.wocc.com.br";
export const maps_test_url =
  (process.env.MAP_STORAGE_PROTOCOL ?? "http") +
  "://" +
  maps_domain +
  "/tests/";
export function publicTestMapUrl(
  path: string,
  testSlug: string,
  rendererMode: string | undefined = undefined
) {
  if (rendererMode === undefined) {
    rendererMode = RENDERER_MODE;
  }

  return new URL(
    `/_/${testSlug}/${maps_domain}/${path}?phaserMode=${rendererMode}`,
    play_url
  ).toString();
}

export const matrix_server_url = process.env.MATRIX_PUBLIC_URI ?? "http://matrix.wocc.com.br";

export const matrix_domain = process.env.MATRIX_DOMAIN ?? "matrix.wocc.com.br";
