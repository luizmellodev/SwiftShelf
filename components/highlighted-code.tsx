import { useMemo } from "react"
import { tokenizeSwiftLines } from "@/lib/swift-highlight"

export function HighlightedCode({ code, startLine = 1 }: { code: string; startLine?: number }) {
  const lines = useMemo(() => tokenizeSwiftLines(code.replace(/\s+$/, "")), [code])
  const gutterWidth = `${String(startLine + lines.length).length + 1}ch`

  return (
    <pre className="code-block overflow-x-auto py-4 text-[12.5px] leading-[1.65] sm:text-[13px]">
      <code className="block min-w-max">
        {lines.map((tokens, i) => (
          <span key={i} className="flex">
            <span
              aria-hidden="true"
              className="sticky left-0 shrink-0 select-none bg-[#1f1f24] pr-4 pl-4 text-right text-[#6c7986]/70"
              style={{ width: `calc(${gutterWidth} + 2rem)` }}
            >
              {startLine + i}
            </span>
            <span className="pr-6">
              {tokens.length === 0
                ? "​"
                : tokens.map((t, j) =>
                    t.kind === "plain" ? t.text : <span key={j} className={`tok-${t.kind}`}>{t.text}</span>,
                  )}
            </span>
          </span>
        ))}
      </code>
    </pre>
  )
}
