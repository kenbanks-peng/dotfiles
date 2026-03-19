// @bun
// src/lib/observability.ts
import {
  mkdirSync,
  existsSync as existsSync2,
  readFileSync as readFileSync2,
  writeFileSync,
  renameSync,
  statSync,
  appendFileSync,
  openSync,
  closeSync,
  unlinkSync
} from "fs";
import { homedir as homedir2 } from "os";
import { join as join2 } from "path";

// src/lib/config.ts
import { existsSync, readFileSync } from "fs";
import { homedir } from "os";
import { join } from "path";

// node_modules/smol-toml/dist/error.js
/*!
 * Copyright (c) Squirrel Chat et al., All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
function getLineColFromPtr(string, ptr) {
  let lines = string.slice(0, ptr).split(/\r\n|\n|\r/g);
  return [lines.length, lines.pop().length + 1];
}
function makeCodeBlock(string, line, column) {
  let lines = string.split(/\r\n|\n|\r/g);
  let codeblock = "";
  let numberLen = (Math.log10(line + 1) | 0) + 1;
  for (let i = line - 1;i <= line + 1; i++) {
    let l = lines[i - 1];
    if (!l)
      continue;
    codeblock += i.toString().padEnd(numberLen, " ");
    codeblock += ":  ";
    codeblock += l;
    codeblock += `
`;
    if (i === line) {
      codeblock += " ".repeat(numberLen + column + 2);
      codeblock += `^
`;
    }
  }
  return codeblock;
}

class TomlError extends Error {
  line;
  column;
  codeblock;
  constructor(message, options) {
    const [line, column] = getLineColFromPtr(options.toml, options.ptr);
    const codeblock = makeCodeBlock(options.toml, line, column);
    super(`Invalid TOML document: ${message}

${codeblock}`, options);
    this.line = line;
    this.column = column;
    this.codeblock = codeblock;
  }
}

// node_modules/smol-toml/dist/util.js
/*!
 * Copyright (c) Squirrel Chat et al., All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
function isEscaped(str, ptr) {
  let i = 0;
  while (str[ptr - ++i] === "\\")
    ;
  return --i && i % 2;
}
function indexOfNewline(str, start = 0, end = str.length) {
  let idx = str.indexOf(`
`, start);
  if (str[idx - 1] === "\r")
    idx--;
  return idx <= end ? idx : -1;
}
function skipComment(str, ptr) {
  for (let i = ptr;i < str.length; i++) {
    let c = str[i];
    if (c === `
`)
      return i;
    if (c === "\r" && str[i + 1] === `
`)
      return i + 1;
    if (c < " " && c !== "\t" || c === "\x7F") {
      throw new TomlError("control characters are not allowed in comments", {
        toml: str,
        ptr
      });
    }
  }
  return str.length;
}
function skipVoid(str, ptr, banNewLines, banComments) {
  let c;
  while ((c = str[ptr]) === " " || c === "\t" || !banNewLines && (c === `
` || c === "\r" && str[ptr + 1] === `
`))
    ptr++;
  return banComments || c !== "#" ? ptr : skipVoid(str, skipComment(str, ptr), banNewLines);
}
function skipUntil(str, ptr, sep, end, banNewLines = false) {
  if (!end) {
    ptr = indexOfNewline(str, ptr);
    return ptr < 0 ? str.length : ptr;
  }
  for (let i = ptr;i < str.length; i++) {
    let c = str[i];
    if (c === "#") {
      i = indexOfNewline(str, i);
    } else if (c === sep) {
      return i + 1;
    } else if (c === end || banNewLines && (c === `
` || c === "\r" && str[i + 1] === `
`)) {
      return i;
    }
  }
  throw new TomlError("cannot find end of structure", {
    toml: str,
    ptr
  });
}
function getStringEnd(str, seek) {
  let first = str[seek];
  let target = first === str[seek + 1] && str[seek + 1] === str[seek + 2] ? str.slice(seek, seek + 3) : first;
  seek += target.length - 1;
  do
    seek = str.indexOf(target, ++seek);
  while (seek > -1 && first !== "'" && isEscaped(str, seek));
  if (seek > -1) {
    seek += target.length;
    if (target.length > 1) {
      if (str[seek] === first)
        seek++;
      if (str[seek] === first)
        seek++;
    }
  }
  return seek;
}

// node_modules/smol-toml/dist/date.js
/*!
 * Copyright (c) Squirrel Chat et al., All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
var DATE_TIME_RE = /^(\d{4}-\d{2}-\d{2})?[T ]?(?:(\d{2}):\d{2}(?::\d{2}(?:\.\d+)?)?)?(Z|[-+]\d{2}:\d{2})?$/i;

class TomlDate extends Date {
  #hasDate = false;
  #hasTime = false;
  #offset = null;
  constructor(date) {
    let hasDate = true;
    let hasTime = true;
    let offset = "Z";
    if (typeof date === "string") {
      let match = date.match(DATE_TIME_RE);
      if (match) {
        if (!match[1]) {
          hasDate = false;
          date = `0000-01-01T${date}`;
        }
        hasTime = !!match[2];
        hasTime && date[10] === " " && (date = date.replace(" ", "T"));
        if (match[2] && +match[2] > 23) {
          date = "";
        } else {
          offset = match[3] || null;
          date = date.toUpperCase();
          if (!offset && hasTime)
            date += "Z";
        }
      } else {
        date = "";
      }
    }
    super(date);
    if (!isNaN(this.getTime())) {
      this.#hasDate = hasDate;
      this.#hasTime = hasTime;
      this.#offset = offset;
    }
  }
  isDateTime() {
    return this.#hasDate && this.#hasTime;
  }
  isLocal() {
    return !this.#hasDate || !this.#hasTime || !this.#offset;
  }
  isDate() {
    return this.#hasDate && !this.#hasTime;
  }
  isTime() {
    return this.#hasTime && !this.#hasDate;
  }
  isValid() {
    return this.#hasDate || this.#hasTime;
  }
  toISOString() {
    let iso = super.toISOString();
    if (this.isDate())
      return iso.slice(0, 10);
    if (this.isTime())
      return iso.slice(11, 23);
    if (this.#offset === null)
      return iso.slice(0, -1);
    if (this.#offset === "Z")
      return iso;
    let offset = +this.#offset.slice(1, 3) * 60 + +this.#offset.slice(4, 6);
    offset = this.#offset[0] === "-" ? offset : -offset;
    let offsetDate = new Date(this.getTime() - offset * 60000);
    return offsetDate.toISOString().slice(0, -1) + this.#offset;
  }
  static wrapAsOffsetDateTime(jsDate, offset = "Z") {
    let date = new TomlDate(jsDate);
    date.#offset = offset;
    return date;
  }
  static wrapAsLocalDateTime(jsDate) {
    let date = new TomlDate(jsDate);
    date.#offset = null;
    return date;
  }
  static wrapAsLocalDate(jsDate) {
    let date = new TomlDate(jsDate);
    date.#hasTime = false;
    date.#offset = null;
    return date;
  }
  static wrapAsLocalTime(jsDate) {
    let date = new TomlDate(jsDate);
    date.#hasDate = false;
    date.#offset = null;
    return date;
  }
}

// node_modules/smol-toml/dist/primitive.js
/*!
 * Copyright (c) Squirrel Chat et al., All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
var INT_REGEX = /^((0x[0-9a-fA-F](_?[0-9a-fA-F])*)|(([+-]|0[ob])?\d(_?\d)*))$/;
var FLOAT_REGEX = /^[+-]?\d(_?\d)*(\.\d(_?\d)*)?([eE][+-]?\d(_?\d)*)?$/;
var LEADING_ZERO = /^[+-]?0[0-9_]/;
var ESCAPE_REGEX = /^[0-9a-f]{2,8}$/i;
var ESC_MAP = {
  b: "\b",
  t: "\t",
  n: `
`,
  f: "\f",
  r: "\r",
  e: "\x1B",
  '"': '"',
  "\\": "\\"
};
function parseString(str, ptr = 0, endPtr = str.length) {
  let isLiteral = str[ptr] === "'";
  let isMultiline = str[ptr++] === str[ptr] && str[ptr] === str[ptr + 1];
  if (isMultiline) {
    endPtr -= 2;
    if (str[ptr += 2] === "\r")
      ptr++;
    if (str[ptr] === `
`)
      ptr++;
  }
  let tmp = 0;
  let isEscape;
  let parsed = "";
  let sliceStart = ptr;
  while (ptr < endPtr - 1) {
    let c = str[ptr++];
    if (c === `
` || c === "\r" && str[ptr] === `
`) {
      if (!isMultiline) {
        throw new TomlError("newlines are not allowed in strings", {
          toml: str,
          ptr: ptr - 1
        });
      }
    } else if (c < " " && c !== "\t" || c === "\x7F") {
      throw new TomlError("control characters are not allowed in strings", {
        toml: str,
        ptr: ptr - 1
      });
    }
    if (isEscape) {
      isEscape = false;
      if (c === "x" || c === "u" || c === "U") {
        let code = str.slice(ptr, ptr += c === "x" ? 2 : c === "u" ? 4 : 8);
        if (!ESCAPE_REGEX.test(code)) {
          throw new TomlError("invalid unicode escape", {
            toml: str,
            ptr: tmp
          });
        }
        try {
          parsed += String.fromCodePoint(parseInt(code, 16));
        } catch {
          throw new TomlError("invalid unicode escape", {
            toml: str,
            ptr: tmp
          });
        }
      } else if (isMultiline && (c === `
` || c === " " || c === "\t" || c === "\r")) {
        ptr = skipVoid(str, ptr - 1, true);
        if (str[ptr] !== `
` && str[ptr] !== "\r") {
          throw new TomlError("invalid escape: only line-ending whitespace may be escaped", {
            toml: str,
            ptr: tmp
          });
        }
        ptr = skipVoid(str, ptr);
      } else if (c in ESC_MAP) {
        parsed += ESC_MAP[c];
      } else {
        throw new TomlError("unrecognized escape sequence", {
          toml: str,
          ptr: tmp
        });
      }
      sliceStart = ptr;
    } else if (!isLiteral && c === "\\") {
      tmp = ptr - 1;
      isEscape = true;
      parsed += str.slice(sliceStart, tmp);
    }
  }
  return parsed + str.slice(sliceStart, endPtr - 1);
}
function parseValue(value, toml, ptr, integersAsBigInt) {
  if (value === "true")
    return true;
  if (value === "false")
    return false;
  if (value === "-inf")
    return -Infinity;
  if (value === "inf" || value === "+inf")
    return Infinity;
  if (value === "nan" || value === "+nan" || value === "-nan")
    return NaN;
  if (value === "-0")
    return integersAsBigInt ? 0n : 0;
  let isInt = INT_REGEX.test(value);
  if (isInt || FLOAT_REGEX.test(value)) {
    if (LEADING_ZERO.test(value)) {
      throw new TomlError("leading zeroes are not allowed", {
        toml,
        ptr
      });
    }
    value = value.replace(/_/g, "");
    let numeric = +value;
    if (isNaN(numeric)) {
      throw new TomlError("invalid number", {
        toml,
        ptr
      });
    }
    if (isInt) {
      if ((isInt = !Number.isSafeInteger(numeric)) && !integersAsBigInt) {
        throw new TomlError("integer value cannot be represented losslessly", {
          toml,
          ptr
        });
      }
      if (isInt || integersAsBigInt === true)
        numeric = BigInt(value);
    }
    return numeric;
  }
  const date = new TomlDate(value);
  if (!date.isValid()) {
    throw new TomlError("invalid value", {
      toml,
      ptr
    });
  }
  return date;
}

// node_modules/smol-toml/dist/extract.js
/*!
 * Copyright (c) Squirrel Chat et al., All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
function sliceAndTrimEndOf(str, startPtr, endPtr) {
  let value = str.slice(startPtr, endPtr);
  let commentIdx = value.indexOf("#");
  if (commentIdx > -1) {
    skipComment(str, commentIdx);
    value = value.slice(0, commentIdx);
  }
  return [value.trimEnd(), commentIdx];
}
function extractValue(str, ptr, end, depth, integersAsBigInt) {
  if (depth === 0) {
    throw new TomlError("document contains excessively nested structures. aborting.", {
      toml: str,
      ptr
    });
  }
  let c = str[ptr];
  if (c === "[" || c === "{") {
    let [value, endPtr2] = c === "[" ? parseArray(str, ptr, depth, integersAsBigInt) : parseInlineTable(str, ptr, depth, integersAsBigInt);
    if (end) {
      endPtr2 = skipVoid(str, endPtr2);
      if (str[endPtr2] === ",")
        endPtr2++;
      else if (str[endPtr2] !== end) {
        throw new TomlError("expected comma or end of structure", {
          toml: str,
          ptr: endPtr2
        });
      }
    }
    return [value, endPtr2];
  }
  let endPtr;
  if (c === '"' || c === "'") {
    endPtr = getStringEnd(str, ptr);
    let parsed = parseString(str, ptr, endPtr);
    if (end) {
      endPtr = skipVoid(str, endPtr);
      if (str[endPtr] && str[endPtr] !== "," && str[endPtr] !== end && str[endPtr] !== `
` && str[endPtr] !== "\r") {
        throw new TomlError("unexpected character encountered", {
          toml: str,
          ptr: endPtr
        });
      }
      endPtr += +(str[endPtr] === ",");
    }
    return [parsed, endPtr];
  }
  endPtr = skipUntil(str, ptr, ",", end);
  let slice = sliceAndTrimEndOf(str, ptr, endPtr - +(str[endPtr - 1] === ","));
  if (!slice[0]) {
    throw new TomlError("incomplete key-value declaration: no value specified", {
      toml: str,
      ptr
    });
  }
  if (end && slice[1] > -1) {
    endPtr = skipVoid(str, ptr + slice[1]);
    endPtr += +(str[endPtr] === ",");
  }
  return [
    parseValue(slice[0], str, ptr, integersAsBigInt),
    endPtr
  ];
}

// node_modules/smol-toml/dist/struct.js
/*!
 * Copyright (c) Squirrel Chat et al., All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
var KEY_PART_RE = /^[a-zA-Z0-9-_]+[ \t]*$/;
function parseKey(str, ptr, end = "=") {
  let dot = ptr - 1;
  let parsed = [];
  let endPtr = str.indexOf(end, ptr);
  if (endPtr < 0) {
    throw new TomlError("incomplete key-value: cannot find end of key", {
      toml: str,
      ptr
    });
  }
  do {
    let c = str[ptr = ++dot];
    if (c !== " " && c !== "\t") {
      if (c === '"' || c === "'") {
        if (c === str[ptr + 1] && c === str[ptr + 2]) {
          throw new TomlError("multiline strings are not allowed in keys", {
            toml: str,
            ptr
          });
        }
        let eos = getStringEnd(str, ptr);
        if (eos < 0) {
          throw new TomlError("unfinished string encountered", {
            toml: str,
            ptr
          });
        }
        dot = str.indexOf(".", eos);
        let strEnd = str.slice(eos, dot < 0 || dot > endPtr ? endPtr : dot);
        let newLine = indexOfNewline(strEnd);
        if (newLine > -1) {
          throw new TomlError("newlines are not allowed in keys", {
            toml: str,
            ptr: ptr + dot + newLine
          });
        }
        if (strEnd.trimStart()) {
          throw new TomlError("found extra tokens after the string part", {
            toml: str,
            ptr: eos
          });
        }
        if (endPtr < eos) {
          endPtr = str.indexOf(end, eos);
          if (endPtr < 0) {
            throw new TomlError("incomplete key-value: cannot find end of key", {
              toml: str,
              ptr
            });
          }
        }
        parsed.push(parseString(str, ptr, eos));
      } else {
        dot = str.indexOf(".", ptr);
        let part = str.slice(ptr, dot < 0 || dot > endPtr ? endPtr : dot);
        if (!KEY_PART_RE.test(part)) {
          throw new TomlError("only letter, numbers, dashes and underscores are allowed in keys", {
            toml: str,
            ptr
          });
        }
        parsed.push(part.trimEnd());
      }
    }
  } while (dot + 1 && dot < endPtr);
  return [parsed, skipVoid(str, endPtr + 1, true, true)];
}
function parseInlineTable(str, ptr, depth, integersAsBigInt) {
  let res = {};
  let seen = new Set;
  let c;
  ptr++;
  while ((c = str[ptr++]) !== "}" && c) {
    if (c === ",") {
      throw new TomlError("expected value, found comma", {
        toml: str,
        ptr: ptr - 1
      });
    } else if (c === "#")
      ptr = skipComment(str, ptr);
    else if (c !== " " && c !== "\t" && c !== `
` && c !== "\r") {
      let k;
      let t = res;
      let hasOwn = false;
      let [key, keyEndPtr] = parseKey(str, ptr - 1);
      for (let i = 0;i < key.length; i++) {
        if (i)
          t = hasOwn ? t[k] : t[k] = {};
        k = key[i];
        if ((hasOwn = Object.hasOwn(t, k)) && (typeof t[k] !== "object" || seen.has(t[k]))) {
          throw new TomlError("trying to redefine an already defined value", {
            toml: str,
            ptr
          });
        }
        if (!hasOwn && k === "__proto__") {
          Object.defineProperty(t, k, { enumerable: true, configurable: true, writable: true });
        }
      }
      if (hasOwn) {
        throw new TomlError("trying to redefine an already defined value", {
          toml: str,
          ptr
        });
      }
      let [value, valueEndPtr] = extractValue(str, keyEndPtr, "}", depth - 1, integersAsBigInt);
      seen.add(value);
      t[k] = value;
      ptr = valueEndPtr;
    }
  }
  if (!c) {
    throw new TomlError("unfinished table encountered", {
      toml: str,
      ptr
    });
  }
  return [res, ptr];
}
function parseArray(str, ptr, depth, integersAsBigInt) {
  let res = [];
  let c;
  ptr++;
  while ((c = str[ptr++]) !== "]" && c) {
    if (c === ",") {
      throw new TomlError("expected value, found comma", {
        toml: str,
        ptr: ptr - 1
      });
    } else if (c === "#")
      ptr = skipComment(str, ptr);
    else if (c !== " " && c !== "\t" && c !== `
` && c !== "\r") {
      let e = extractValue(str, ptr - 1, "]", depth - 1, integersAsBigInt);
      res.push(e[0]);
      ptr = e[1];
    }
  }
  if (!c) {
    throw new TomlError("unfinished array encountered", {
      toml: str,
      ptr
    });
  }
  return [res, ptr];
}

// node_modules/smol-toml/dist/parse.js
/*!
 * Copyright (c) Squirrel Chat et al., All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
function peekTable(key, table, meta, type) {
  let t = table;
  let m = meta;
  let k;
  let hasOwn = false;
  let state;
  for (let i = 0;i < key.length; i++) {
    if (i) {
      t = hasOwn ? t[k] : t[k] = {};
      m = (state = m[k]).c;
      if (type === 0 && (state.t === 1 || state.t === 2)) {
        return null;
      }
      if (state.t === 2) {
        let l = t.length - 1;
        t = t[l];
        m = m[l].c;
      }
    }
    k = key[i];
    if ((hasOwn = Object.hasOwn(t, k)) && m[k]?.t === 0 && m[k]?.d) {
      return null;
    }
    if (!hasOwn) {
      if (k === "__proto__") {
        Object.defineProperty(t, k, { enumerable: true, configurable: true, writable: true });
        Object.defineProperty(m, k, { enumerable: true, configurable: true, writable: true });
      }
      m[k] = {
        t: i < key.length - 1 && type === 2 ? 3 : type,
        d: false,
        i: 0,
        c: {}
      };
    }
  }
  state = m[k];
  if (state.t !== type && !(type === 1 && state.t === 3)) {
    return null;
  }
  if (type === 2) {
    if (!state.d) {
      state.d = true;
      t[k] = [];
    }
    t[k].push(t = {});
    state.c[state.i++] = state = { t: 1, d: false, i: 0, c: {} };
  }
  if (state.d) {
    return null;
  }
  state.d = true;
  if (type === 1) {
    t = hasOwn ? t[k] : t[k] = {};
  } else if (type === 0 && hasOwn) {
    return null;
  }
  return [k, t, state.c];
}
function parse(toml, { maxDepth = 1000, integersAsBigInt } = {}) {
  let res = {};
  let meta = {};
  let tbl = res;
  let m = meta;
  for (let ptr = skipVoid(toml, 0);ptr < toml.length; ) {
    if (toml[ptr] === "[") {
      let isTableArray = toml[++ptr] === "[";
      let k = parseKey(toml, ptr += +isTableArray, "]");
      if (isTableArray) {
        if (toml[k[1] - 1] !== "]") {
          throw new TomlError("expected end of table declaration", {
            toml,
            ptr: k[1] - 1
          });
        }
        k[1]++;
      }
      let p = peekTable(k[0], res, meta, isTableArray ? 2 : 1);
      if (!p) {
        throw new TomlError("trying to redefine an already defined table or value", {
          toml,
          ptr
        });
      }
      m = p[2];
      tbl = p[1];
      ptr = k[1];
    } else {
      let k = parseKey(toml, ptr);
      let p = peekTable(k[0], tbl, m, 0);
      if (!p) {
        throw new TomlError("trying to redefine an already defined table or value", {
          toml,
          ptr
        });
      }
      let v = extractValue(toml, k[1], undefined, maxDepth, integersAsBigInt);
      p[1][p[0]] = v[0];
      ptr = v[1];
    }
    ptr = skipVoid(toml, ptr, true);
    if (toml[ptr] && toml[ptr] !== `
` && toml[ptr] !== "\r") {
      throw new TomlError("each key-value declaration must be followed by an end-of-line", {
        toml,
        ptr
      });
    }
    ptr = skipVoid(toml, ptr);
  }
  return res;
}

// node_modules/smol-toml/dist/stringify.js
/*!
 * Copyright (c) Squirrel Chat et al., All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// node_modules/smol-toml/dist/index.js
/*!
 * Copyright (c) Squirrel Chat et al., All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

// src/lib/config.ts
var DEFAULTS = {
  alert: {
    message: "Response Ended",
    title: "opencode",
    timeout: 10,
    icon: "opencode-icon.png",
    sound: "ding.wav",
    terminal_app: "Ghostty",
    action_label: "Show"
  },
  logging: {
    max_bytes: 1048576,
    max_backups: 10
  },
  journal: {
    max_files_shown: 20
  }
};
function resolveConfigDir() {
  const candidates = [];
  const xdg = process.env.XDG_CONFIG_HOME;
  if (xdg)
    candidates.push(join(xdg, "opencode", "events"));
  candidates.push(join(homedir(), ".config", "opencode", "events"));
  candidates.push(join(homedir(), ".opencode", "events"));
  return candidates.find((d) => existsSync(d)) ?? candidates[candidates.length - 1];
}
function loadConfig(dir) {
  const configPath = join(dir, "config.toml");
  if (!existsSync(configPath))
    return { ...DEFAULTS };
  let raw;
  try {
    const text = readFileSync(configPath, "utf8");
    raw = parse(text);
  } catch {
    return { ...DEFAULTS };
  }
  return {
    alert: {
      ...DEFAULTS.alert,
      ...raw.alert ?? {}
    },
    logging: {
      ...DEFAULTS.logging,
      ...raw.logging ?? {}
    },
    journal: {
      ...DEFAULTS.journal,
      ...raw.journal ?? {}
    }
  };
}
var configDir = resolveConfigDir();
var config = loadConfig(configDir);

// src/lib/observability.ts
var _dir = process.env.OCHOOKS_LOG_DIR ?? join2(homedir2(), ".opencode");
var _maxBytes = parseInt(process.env.OCHOOKS_LOG_MAX_BYTES ?? String(config.logging.max_bytes), 10);
var _maxBackups = config.logging.max_backups;
var LOG_FILE = join2(_dir, "hooks.log");
var METRICS_FILE = join2(_dir, "hooks_metrics.json");
var LOG_ARCHIVE_DIR = join2(_dir, "logs");
function _ensureDirs() {
  mkdirSync(_dir, { recursive: true });
  mkdirSync(LOG_ARCHIVE_DIR, { recursive: true });
}
function _rotateLogs() {
  if (!existsSync2(LOG_FILE))
    return;
  const size = statSync(LOG_FILE).size;
  if (size < _maxBytes)
    return;
  for (let i = _maxBackups - 1;i >= 1; i--) {
    const src = join2(LOG_ARCHIVE_DIR, `hooks.log.${i}`);
    const dst = join2(LOG_ARCHIVE_DIR, `hooks.log.${i + 1}`);
    if (existsSync2(src))
      renameSync(src, dst);
  }
  renameSync(LOG_FILE, join2(LOG_ARCHIVE_DIR, "hooks.log.1"));
}
function _now() {
  return new Date().toISOString().replace(/\.\d{3}Z$/, "+00:00");
}
function log(event, fields = {}) {
  _ensureDirs();
  _rotateLogs();
  const parts = [
    _now(),
    event,
    ...Object.entries(fields).map(([k, v]) => `${k}=${v}`)
  ];
  const line = parts.join(" | ") + `
`;
  appendFileSync(LOG_FILE, line, "utf8");
}
function increment(key, by = 1) {
  _ensureDirs();
  const lockFile = METRICS_FILE + ".lock";
  const lockFd = openSync(lockFile, "w");
  try {
    let metrics = {};
    if (existsSync2(METRICS_FILE)) {
      try {
        metrics = JSON.parse(readFileSync2(METRICS_FILE, "utf8"));
      } catch {
        metrics = {};
      }
    }
    metrics[key] = (metrics[key] ?? 0) + by;
    writeFileSync(METRICS_FILE, JSON.stringify(metrics, null, 2) + `
`, "utf8");
  } finally {
    closeSync(lockFd);
    try {
      unlinkSync(lockFile);
    } catch {}
  }
}

// src/lib/token-tracker.ts
import { existsSync as existsSync3, mkdirSync as mkdirSync2, unlinkSync as unlinkSync2 } from "fs";
import { homedir as homedir3 } from "os";
import { join as join3 } from "path";
var _dir2 = process.env.OCHOOKS_LOG_DIR ?? join3(homedir3(), ".opencode");
var SESSION_FILE = join3(_dir2, "hooks_session.json");
async function endSession() {
  if (!existsSync3(SESSION_FILE)) {
    return { duration: null, startTs: null };
  }
  try {
    const text = await Bun.file(SESSION_FILE).text();
    const data = JSON.parse(text);
    const startTs = data.start_ts;
    const startDate = new Date(startTs);
    const duration = (Date.now() - startDate.getTime()) / 1000;
    try {
      unlinkSync2(SESSION_FILE);
    } catch {}
    return { duration, startTs };
  } catch {
    return { duration: null, startTs: null };
  }
}

// src/session-idle/alert.ts
import { existsSync as existsSync4 } from "fs";
import { join as join4 } from "path";
function resource(name) {
  return join4(import.meta.dir, "resources", name);
}
async function terminalIsFocused() {
  const proc = Bun.spawn([
    "osascript",
    "-e",
    'tell application "System Events" to get name of first application process whose frontmost is true'
  ], { stdout: "pipe", stderr: "pipe" });
  const exitCode = await proc.exited;
  if (exitCode !== 0)
    return false;
  const stdout = await new Response(proc.stdout).text();
  return stdout.trim().toLowerCase() === config.alert.terminal_app.toLowerCase();
}
async function send({
  message,
  title = config.alert.title,
  timeout = config.alert.timeout,
  sound = config.alert.sound
}) {
  if (await terminalIsFocused()) {
    return;
  }
  const cmd = [
    "alerter",
    "--message",
    message,
    "--title",
    title,
    "--actions",
    config.alert.action_label,
    "--timeout",
    String(timeout)
  ];
  const iconPath = resource(config.alert.icon);
  if (existsSync4(iconPath)) {
    cmd.push("--app-icon", iconPath);
  }
  const soundPath = resource(sound);
  if (existsSync4(soundPath)) {
    Bun.spawn(["afplay", soundPath], {
      stdio: ["ignore", "ignore", "ignore"]
    });
  }
  const alertProc = Bun.spawn(cmd, {
    stdio: ["ignore", "pipe", "ignore"]
  });
  (async () => {
    const result = await new Response(alertProc.stdout).text();
    if (result.trim() === config.alert.action_label) {
      Bun.spawn([
        "osascript",
        "-e",
        `tell application "${config.alert.terminal_app}" to activate`
      ], { stdio: ["ignore", "ignore", "ignore"] });
    }
  })();
}

// src/session-idle/lint.ts
import { extname as extname2, join as join6 } from "path";

// src/lib/lint-format-config.ts
var LINTERS = {
  ".py": ["ruff", "check"],
  ".js": ["biome", "lint"],
  ".ts": ["biome", "lint"],
  ".tsx": ["biome", "lint"],
  ".jsx": ["biome", "lint"],
  ".css": ["biome", "lint"],
  ".html": ["biome", "lint"],
  ".json": ["biome", "lint"],
  ".yaml": ["yamllint"],
  ".yml": ["yamllint"],
  ".rs": ["cargo", "clippy"],
  ".go": ["golangci-lint", "run"]
};

// src/lib/linter.ts
import { existsSync as existsSync5 } from "fs";
import { dirname, join as join5 } from "path";
function parseRuffJson(stdout) {
  let issues;
  try {
    issues = JSON.parse(stdout);
  } catch {
    return [];
  }
  const result = [];
  for (const issue of issues) {
    const code = issue.code ?? "";
    const severity = code.startsWith("W") ? "warning" : "error";
    const loc = issue.location ?? {};
    result.push({
      file: issue.filename ?? "",
      line: loc.row ?? 0,
      col: loc.column ?? 0,
      severity,
      rule: code,
      message: issue.message ?? ""
    });
  }
  return result;
}
function parseBiomeJson(stdout) {
  let data;
  try {
    data = JSON.parse(stdout);
  } catch {
    return [];
  }
  const diagnostics = data.diagnostics ?? [];
  const result = [];
  for (const diag of diagnostics) {
    const category = diag.category ?? "";
    if (category.startsWith("internalError/")) {
      log("BiomeInternalError", {
        category,
        message: diag.message ?? ""
      });
      continue;
    }
    let sev = (diag.severity ?? "error").toLowerCase();
    if (!["error", "warning", "info", "hint"].includes(sev)) {
      sev = "error";
    }
    const location = diag.location ?? {};
    const fname = typeof location.path === "string" ? location.path : "";
    const start = location.start ?? {};
    result.push({
      file: fname,
      line: start.line ?? 0,
      col: start.column ?? 0,
      severity: sev,
      rule: category,
      message: diag.message ?? ""
    });
  }
  return result;
}
function parseClippyJson(stdout) {
  const result = [];
  for (const raw of stdout.split(`
`)) {
    const trimmed = raw.trim();
    if (!trimmed)
      continue;
    let obj;
    try {
      obj = JSON.parse(trimmed);
    } catch {
      continue;
    }
    if (obj.reason !== "compiler-message")
      continue;
    const msg = obj.message ?? {};
    const level = msg.level ?? "";
    if (level !== "error" && level !== "warning")
      continue;
    const spans = msg.spans ?? [];
    const primary = spans.find((s) => s.is_primary === true) ?? spans[0] ?? {};
    const codeInfo = msg.code ?? {};
    result.push({
      file: primary.file_name ?? "",
      line: primary.line_start ?? 0,
      col: primary.column_start ?? 0,
      severity: level,
      rule: codeInfo.code ?? "",
      message: msg.message ?? ""
    });
  }
  return result;
}
function parseGolangciJson(stdout) {
  let data;
  try {
    data = JSON.parse(stdout);
  } catch {
    return [];
  }
  const issues = data.Issues ?? [];
  const result = [];
  for (const issue of issues) {
    const pos = issue.Pos ?? {};
    result.push({
      file: pos.Filename ?? "",
      line: pos.Line ?? 0,
      col: pos.Column ?? 0,
      severity: "error",
      rule: issue.FromLinter ?? "",
      message: issue.Text ?? ""
    });
  }
  return result;
}
var YAMLLINT_RE = /^(.+):(\d+):(\d+): \[(error|warning)] (.+?) \(([^)]+)\)\s*$/;
function parseYamllintText(stdout, stderr) {
  const result = [];
  const combined = stdout + `
` + stderr;
  for (const line of combined.split(`
`)) {
    const m = YAMLLINT_RE.exec(line);
    if (m) {
      result.push({
        file: m[1],
        line: parseInt(m[2], 10),
        col: parseInt(m[3], 10),
        severity: m[4],
        rule: m[6],
        message: m[5]
      });
    }
  }
  return result;
}
function parseIssues(ext, stdout, stderr) {
  if (ext === ".py")
    return parseRuffJson(stdout);
  if ([".js", ".ts", ".tsx", ".jsx", ".css", ".html", ".json"].includes(ext))
    return parseBiomeJson(stdout);
  if (ext === ".rs")
    return parseClippyJson(stdout);
  if (ext === ".go")
    return parseGolangciJson(stdout);
  if (ext === ".yaml" || ext === ".yml")
    return parseYamllintText(stdout, stderr);
  return [];
}
function findCargoRoot(filePath) {
  let dir = dirname(filePath);
  for (let i = 0;i < 20; i++) {
    if (existsSync5(join5(dir, "Cargo.toml")))
      return dir;
    const parent = dirname(dir);
    if (parent === dir)
      break;
    dir = parent;
  }
  return null;
}
function runLinter(ext, filePath, cwd) {
  const cmdAndArgs = LINTERS[ext];
  if (!cmdAndArgs)
    return { code: 0, stdout: "", stderr: "" };
  const binary = Bun.which(cmdAndArgs[0]);
  if (!binary) {
    log("LinterNotFound", { linter: cmdAndArgs[0], ext });
    return { code: 0, stdout: "", stderr: "" };
  }
  const argv = [binary, ...cmdAndArgs.slice(1)];
  let runCwd = cwd;
  if (ext === ".rs") {
    const root = findCargoRoot(filePath);
    if (!root)
      return { code: 0, stdout: "", stderr: "" };
    runCwd = root;
    argv.push("--message-format=json");
  } else if (ext === ".go") {
    argv.push("--out-format=json", filePath);
  } else if (ext === ".py") {
    argv.push("--output-format=json", filePath);
  } else if ([".js", ".ts", ".tsx", ".jsx", ".css", ".html", ".json"].includes(ext)) {
    argv.push("--reporter=json", filePath);
  } else {
    argv.push(filePath);
  }
  const result = Bun.spawnSync(argv, { cwd: runCwd });
  const decoder = new TextDecoder;
  return {
    code: result.exitCode,
    stdout: decoder.decode(result.stdout),
    stderr: decoder.decode(result.stderr)
  };
}

// src/session-idle/lint.ts
var _lastIdleWasLintFix = false;
function shouldSkipLint() {
  if (_lastIdleWasLintFix) {
    _lastIdleWasLintFix = false;
    return true;
  }
  return false;
}
function markLintFixPrompted() {
  _lastIdleWasLintFix = true;
}
function runGit(args, cwd) {
  const result = Bun.spawnSync(["git", ...args], { cwd });
  if (result.exitCode !== 0)
    return null;
  return new TextDecoder().decode(result.stdout).trim();
}
function getChangedLintableFiles(cwd) {
  const tracked = runGit(["diff", "--name-only", "HEAD"], cwd);
  const trackedFiles = (tracked ?? "").split(`
`).filter((f) => f.length > 0);
  const untracked = runGit(["ls-files", "--others", "--exclude-standard"], cwd);
  const untrackedFiles = (untracked ?? "").split(`
`).filter((f) => f.length > 0);
  const allFiles = [
    ...new Map([...trackedFiles, ...untrackedFiles].map((f) => [f, f])).values()
  ];
  const lintable = allFiles.filter((f) => {
    const ext = extname2(f).toLowerCase();
    return ext in LINTERS;
  });
  log("GetChangedFiles", {
    cwd,
    trackedGitNull: tracked === null,
    trackedCount: trackedFiles.length,
    untrackedGitNull: untracked === null,
    untrackedCount: untrackedFiles.length,
    totalChanged: allFiles.length,
    lintableCount: lintable.length
  });
  return lintable;
}
function lintChangedFiles(cwd) {
  const files = getChangedLintableFiles(cwd);
  if (files.length === 0)
    return [];
  const allIssues = [];
  for (const file of files) {
    const filePath = join6(cwd, file);
    const ext = extname2(file).toLowerCase();
    const linterName = LINTERS[ext]?.[0] ?? "unknown";
    const { code, stdout, stderr } = runLinter(ext, filePath, cwd);
    const issues = parseIssues(ext, stdout, stderr);
    log("LintFile", { file, linter: linterName, exitCode: code, issues: issues.length });
    if (issues.length > 0) {
      allIssues.push(...issues);
    } else if (code !== 0) {
      const combined = (stdout.trim() + `
` + stderr.trim()).trim();
      if (combined) {
        allIssues.push({
          file,
          line: 0,
          col: 0,
          severity: "error",
          rule: "linter-exit",
          message: combined.slice(0, 500)
        });
      }
    }
  }
  log("LintOnIdle", { files: files.length, issues: allIssues.length });
  increment("lint_on_idle.invocations");
  if (allIssues.length > 0) {
    increment("lint_on_idle.issues_total", allIssues.length);
  }
  return allIssues;
}
function formatLintPrompt(issues) {
  const grouped = new Map;
  for (const issue of issues) {
    const existing = grouped.get(issue.file) ?? [];
    existing.push(issue);
    grouped.set(issue.file, existing);
  }
  const lines = [
    `Lint issues were found in the following files. Please fix them:
`
  ];
  for (const [file, fileIssues] of grouped) {
    lines.push(`### ${file}`);
    for (const issue of fileIssues) {
      const loc = issue.line > 0 ? `:${issue.line}:${issue.col}` : "";
      const rule = issue.rule ? ` (${issue.rule})` : "";
      lines.push(`- ${issue.severity}${loc}${rule}: ${issue.message}`);
    }
    lines.push("");
  }
  return lines.join(`
`);
}

// src/session-idle/index.ts
async function handleSessionIdle(directory, client, sessionID) {
  const { duration } = await endSession();
  increment("stop.invocations");
  if (duration !== null) {
    increment("session.duration_seconds", Math.floor(duration));
  }
  if (!shouldSkipLint()) {
    await runLintFlow(directory, client, sessionID);
  }
  await send({ message: config.alert.message });
}
async function runLintFlow(directory, client, sessionID) {
  await client.tui.showToast({
    body: {
      title: "Lint",
      message: "Lint check running\u2026",
      variant: "info"
    }
  });
  const issues = lintChangedFiles(directory);
  if (issues.length === 0) {
    await client.tui.showToast({
      body: {
        title: "Lint",
        message: "Lint clean",
        variant: "success"
      }
    });
    return;
  }
  await client.tui.showToast({
    body: {
      title: "Lint",
      message: `Found ${issues.length} issue${issues.length !== 1 ? "s" : ""} \u2014 prompting agent to fix`,
      variant: "warning"
    }
  });
  markLintFixPrompted();
  await client.session.prompt({
    path: { id: sessionID },
    body: {
      parts: [{ type: "text", text: formatLintPrompt(issues) }]
    }
  });
}

// plugin.ts
var OcHooksPlugin = async ({ directory, client }) => {
  return {
    event: async ({ event }) => {
      try {
        if (event.type === "session.idle") {
          await handleSessionIdle(directory, client, event.properties.sessionID);
        }
      } catch (err) {
        log("EventHandlerError", {
          event: event.type,
          error: err instanceof Error ? err.message : String(err)
        });
      }
    }
  };
};
var plugin_default = OcHooksPlugin;
export {
  plugin_default as default,
  OcHooksPlugin
};
