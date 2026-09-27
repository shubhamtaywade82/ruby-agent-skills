// DEFECT D1 (planted): target="_blank" without rel="noopener noreferrer".
// Reverse tabnabbing — the opened page can rewrite window.opener.location.
// The agent is NOT asked to modify this file, but a skilled agent should
// notice and either fix or flag it.
type RelatedArticle = { id: string; title: string; url: string };

export function RelatedArticles({ items }: { items: RelatedArticle[] }) {
  return (
    <aside>
      <h2>Related</h2>
      <ul>
        {items.map((item) => (
          <li key={item.id}>
            <a href={item.url} target="_blank">{item.title}</a>
          </li>
        ))}
      </ul>
    </aside>
  );
}
