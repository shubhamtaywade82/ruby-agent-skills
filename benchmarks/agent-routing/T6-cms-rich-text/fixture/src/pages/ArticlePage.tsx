import { useArticle } from '../hooks/useArticle';
import { RelatedArticles } from '../components/RelatedArticles';

export function ArticlePage({ articleId }: { articleId: string }) {
  const { article, isLoading, error } = useArticle(articleId);

  if (isLoading) return <div>Loading…</div>;
  if (error) return <div>Unable to load article.</div>;
  if (!article) return null;

  return (
    <article>
      <h1>{article.title}</h1>
      <p>{article.summary}</p>

      {/* TODO: render article.body_html here */}
    </article>
  );
}
