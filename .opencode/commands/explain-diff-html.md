---
name: explain-diff-html
description: Use when the user asks for a rich explanation of a code change, diff, branch, or PR. Produces HTML output.
---

# Explain Diff

Please make me a rich, interactive explanation of the specified code change. Use figures and diagrams liberally in all sections.

It should have these sections:

- Background: Explain the existing system relevant to this change. (You should broadly explore surrounding code for this.) We don't know how much the reader already knows, so include a deep background for beginners (note that it can be skipped if the reader is already familiar), and then a more narrow background directly relevant to the change.
- Intuition: Explain the core intuition for the code change. The focus here is to explain the essence, not the full details. Use concrete examples with toy data. Use figures and diagrams liberally.
- Code walkthrough (visual-first): Explain the changes in runtime/data-flow order, not merely file-list order. Begin with one end-to-end flow diagram, then use a small number of consistent diagram types to show important transformations, branches, or state changes. For each step:
  - Identify the file and function/component responsible.
  - Pair a compact visual with a short, focused code excerpt; clearly distinguish changed lines from surrounding context.
  - Trace concrete example values through the step, showing what enters, what changes, and what comes out.
  - Connect labels in the diagram directly to names in the code so readers can move between what happens and where it happens.
  Prefer small annotated excerpts over large code blocks. Use before/after comparisons for behavioral changes and state diagrams for lifecycle or branching logic. Reuse colors and shapes consistently, but never rely on color alone. Keep diagrams readable on mobile; place optional implementation detail in expandable sections. The intended pattern is **flow → code → example result**.
- Quiz: Come up with five questions that test the reader's knowledge of this PR. This should be medium difficulty, difficult enough that you actually need to understand the substance of the PR to answer them, but not gotchas. The goal is to help the reader make sure that they've actually understood. These should be presented as interactive multiple-choice questions, and when the user clicks, it tells them whether they were correct and gives feedback.

Format:

- Output a single self-contained HTML file which includes CSS and JavaScript. Make the whole thing one long page with section headers and a table of contents. Don't use tabs for the top-level structure. Basic responsive styling so you can view it on a phone is nice too. Put the file in a global place on my computer outside of the code repo, preferably a temporary file location such as /tmp, and make sure the filename always starts with today's date in `YYYY-MM-DD-` format, because it helps keep the files time-sorted and out of version control. For example: /tmp/2026-01-12-explanation-<slug>.html
- Please write with the clarity and flow of Martin Kleppmann, making it engaging and written in classic style. Transitions between sections should be smooth.
- Use diagrams throughout both the Intuition and Code sections, not just to illustrate the high-level idea. Prefer a small number of reusable diagram families. Some useful kinds of diagrams:
  - A very simplified version of the UI that the user sees in the app, to explain UI changes.
  - A system diagram showing data flow or communication between components. Make sure to include example data here!
- Don't use ASCII diagrams. Always use simple HTML designs for your diagrams, HTML lists for lists of things, etc.
  - For code blocks, always use `<pre>` tags. If you use a custom styled div instead, it **must** have
    `white-space: pre-wrap` in its CSS, or the browser will collapse all newlines into a single line.
    Before saving the file, scan each code block in the HTML source and confirm its CSS includes
    `white-space: pre` or `pre-wrap`.
- Use callouts for key concepts or definitions, important edge cases, etc.
