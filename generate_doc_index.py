#!/usr/bin/env python3
"""
Generate a Markdown index of documentation files under brand-docs and assets.
"""
import os

def main():
    top_dirs = ["brand-docs", "assets"]
    md_files = []
    for top in top_dirs:
        if not os.path.isdir(top):
            continue
        for root, _, files in os.walk(top):
            for f in files:
                if f.lower().endswith(".md"):
                    md_files.append(os.path.join(root, f))
    md_files.sort()

    def extract_summary(md_path):
        """Return the first paragraph (non-heading) from a Markdown file."""
        lines = []
        in_para = False
        with open(md_path, encoding="utf-8") as src:
            for raw in src:
                line = raw.strip()
                # skip headings and empty lines before paragraph
                if not line:
                    if in_para:
                        break
                    continue
                if line.startswith("#"):
                    continue
                lines.append(line)
                in_para = True
        return " ".join(lines)

    with open("doc-index.md", "w", encoding="utf-8") as out:
        out.write("# Documentation Index\n\n")
        for top in top_dirs:
            out.write(f"## {top}\n\n")
            for path in md_files:
                if not path.startswith(f"{top}/"):
                    continue
                out.write(f"- [{path}]({path})\n")
                summary = extract_summary(path)
                if summary:
                    out.write(f"  Summary: {summary}\n")
            out.write("\n")

if __name__ == "__main__":
    main()
