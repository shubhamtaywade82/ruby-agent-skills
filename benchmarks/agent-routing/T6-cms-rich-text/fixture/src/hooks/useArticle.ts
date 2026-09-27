import { useEffect, useState } from 'react';

type Article = {
  id: string;
  title: string;
  summary: string;
  body_html: string | null;
};

export function useArticle(articleId: string) {
  const [article, setArticle] = useState<Article | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    let cancelled = false;
    setIsLoading(true);
    fetch(`/api/articles/${articleId}`)
      .then((r) => r.json())
      .then((a: Article) => { if (!cancelled) setArticle(a); })
      .catch((e: Error) => { if (!cancelled) setError(e); })
      .finally(() => { if (!cancelled) setIsLoading(false); });
    return () => { cancelled = true; };
  }, [articleId]);

  return { article, isLoading, error };
}
