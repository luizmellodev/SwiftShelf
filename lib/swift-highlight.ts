/**
 * Tiny Swift tokenizer for display purposes only. It is not a parser: it just
 * needs to colour typical SwiftUI snippets the way Xcode roughly would.
 */

export type TokenKind = "keyword" | "string" | "comment" | "mark" | "number" | "type" | "attr" | "call" | "plain"
export interface Token {
  text: string
  kind: TokenKind
}

const KEYWORDS = new Set(
  (
    "actor any as associatedtype async await break case catch class continue default defer deinit do else enum " +
    "extension fallthrough false fileprivate final for func get guard if import in indirect init inout internal is " +
    "lazy let mutating nil nonisolated open operator override private protocol public repeat rethrows return self " +
    "Self set some static struct subscript super switch throw throws true try typealias var weak where while willSet didSet"
  ).split(" "),
)

const MASTER =
  /(\/\*[\s\S]*?\*\/)|(\/\/[^\n]*)|("""[\s\S]*?""")|("(?:\\.|[^"\\\n])*")|(#?@\w+|#\w+)|(\b\d[\d_]*(?:\.\d+)?\b)|(\.[a-zA-Z_]\w*)|([A-Za-z_]\w*)|(\s+|[^\sA-Za-z_\d"\/.#@]+|.)/gy

export function tokenizeSwift(code: string): Token[] {
  const tokens: Token[] = []
  MASTER.lastIndex = 0
  let m: RegExpExecArray | null
  while (MASTER.lastIndex < code.length && (m = MASTER.exec(code))) {
    const [text, block, line, multi, str, attr, num, member, word] = m
    let kind: TokenKind = "plain"
    if (block) kind = "comment"
    else if (line) kind = /^\/\/\s*MARK:/.test(line) ? "mark" : "comment"
    else if (multi || str) kind = "string"
    else if (attr) kind = "attr"
    else if (num) kind = "number"
    else if (member) {
      tokens.push({ text: ".", kind: "plain" }, { text: member.slice(1), kind: "call" })
      continue
    } else if (word) kind = KEYWORDS.has(word) ? "keyword" : /^[A-Z]/.test(word) ? "type" : "plain"
    const last = tokens[tokens.length - 1]
    if (last && last.kind === kind && kind === "plain") last.text += text
    else tokens.push({ text, kind })
  }
  return tokens
}

/** Split tokens into lines so each can get a gutter number. */
export function tokenizeSwiftLines(code: string): Token[][] {
  const lines: Token[][] = [[]]
  for (const token of tokenizeSwift(code)) {
    const parts = token.text.split("\n")
    parts.forEach((part, i) => {
      if (i > 0) lines.push([])
      if (part) lines[lines.length - 1].push({ text: part, kind: token.kind })
    })
  }
  return lines
}
