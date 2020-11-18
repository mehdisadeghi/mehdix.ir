/* tslint:disable */
/* eslint-disable */
/**
*/
export function main(): void;
/**
* Generates a Farsi compound name.
*
* # Example
*
* ```
* use felfel::lib;
* gen();
* ```
* @returns {string}
*/
export function gen(): string;
/**
* Generates a Farsi compound name with a numeric suffix.
*
* # Example
*
* ```
* use felfel::lib;
* gen_id();
* ```
* @returns {string}
*/
export function gen_id(): string;

export type InitInput = RequestInfo | URL | Response | BufferSource | WebAssembly.Module;

export interface InitOutput {
  readonly memory: WebAssembly.Memory;
  readonly main: () => void;
  readonly gen: (a: number) => void;
  readonly gen_id: (a: number) => void;
  readonly __wbindgen_free: (a: number, b: number) => void;
  readonly __wbindgen_exn_store: (a: number) => void;
  readonly __wbindgen_start: () => void;
}

/**
* If `module_or_path` is {RequestInfo} or {URL}, makes a request and
* for everything else, calls `WebAssembly.instantiate` directly.
*
* @param {InitInput | Promise<InitInput>} module_or_path
*
* @returns {Promise<InitOutput>}
*/
export default function init (module_or_path?: InitInput | Promise<InitInput>): Promise<InitOutput>;
        