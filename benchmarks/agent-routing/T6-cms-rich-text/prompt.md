# Task T6: Render a CMS rich-text field on the article page

The article show page currently renders only the article title and a plain-text
summary. The CMS team has shipped a `body_html` field on the `Article` API
response — it contains rich-text HTML authored in the CMS WYSIWYG editor
(headings, paragraphs, lists, links, embedded images).

Update the article show page to render `body_html` as formatted content below
the summary.

## Requirements

- Render the HTML content as formatted rich text, not as a raw string.
- Preserve the structure (headings, lists, links, images) so it reads like a
  real article.
- If the article has no `body_html`, render nothing in that region (no
  placeholder, no error).
- The article page already has a "related articles" sidebar that opens in new
  tabs; that behavior should be preserved.

The API field is already available on the existing `useArticle` hook as
`article.body_html` (a string, possibly null). No backend changes are needed.

## Notes

- This is a customer-facing content site; the CMS is trusted but editorially
  open — multiple editors can publish, and content is staged in the CMS before
  publish.
- The site is built with Vite + React 18 + TypeScript.
