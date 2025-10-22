import express, { Request, Response } from 'express';
import { v4 as uuid } from 'uuid';
import { JsonStorage } from './storage';
import { Article } from './types';

const app = express();
const port = process.env.PORT ?? 3000;
const storage = new JsonStorage(process.env.DATABASE_PATH);

app.use(express.json({ limit: '1mb' }));

function sanitizeArticle(article: Article, userId?: string, purchased = false) {
  const previewLimit = 200;

  if (article.priceCents === 0 || purchased) {
    return { ...article, requiresPurchase: false };
  }

  return {
    ...article,
    content: `${article.content.slice(0, previewLimit)}...`,
    requiresPurchase: true,
    purchased: false,
    previewLength: previewLimit
  };
}

app.get('/health', (_req: Request, res: Response) => {
  res.json({ status: 'ok' });
});

app.get('/articles', async (req: Request, res: Response) => {
  const userId = req.query.userId as string | undefined;
  const [articles, purchases] = await Promise.all([
    storage.listArticles(),
    userId ? storage.listPurchasesForUser(userId) : Promise.resolve([])
  ]);

  const purchasedArticleIds = new Set(purchases.map((purchase) => purchase.articleId));
  const result = articles.map((article) => sanitizeArticle(article, userId, purchasedArticleIds.has(article.id)));

  res.json(result);
});

app.post('/articles', async (req: Request, res: Response) => {
  const { title, content, priceCents = 0, author, synopsis, coverImageUrl } = req.body ?? {};

  if (!title || !content) {
    res.status(400).json({ message: 'Title and content are required' });
    return;
  }

  if (typeof priceCents !== 'number' || priceCents < 0) {
    res.status(400).json({ message: 'priceCents must be a non-negative number' });
    return;
  }

  const now = new Date().toISOString();
  const article: Article = {
    id: uuid(),
    title,
    content,
    priceCents,
    author,
    synopsis,
    coverImageUrl,
    createdAt: now,
    updatedAt: now
  };

  await storage.createArticle(article);
  res.status(201).json(article);
});

app.get('/articles/:id', async (req: Request, res: Response) => {
  const userId = req.query.userId as string | undefined;
  const article = await storage.getArticleById(req.params.id);

  if (!article) {
    res.status(404).json({ message: 'Article not found' });
    return;
  }

  const purchase = userId ? await storage.findPurchase(userId, article.id) : undefined;
  res.json(sanitizeArticle(article, userId, Boolean(purchase)));
});

app.patch('/articles/:id', async (req: Request, res: Response) => {
  const article = await storage.getArticleById(req.params.id);

  if (!article) {
    res.status(404).json({ message: 'Article not found' });
    return;
  }

  const { title, content, priceCents, author, synopsis, coverImageUrl } = req.body ?? {};
  const now = new Date().toISOString();

  const updated: Article = {
    ...article,
    title: typeof title === 'string' ? title : article.title,
    content: typeof content === 'string' ? content : article.content,
    priceCents: typeof priceCents === 'number' && priceCents >= 0 ? priceCents : article.priceCents,
    author: typeof author === 'string' ? author : article.author,
    synopsis: typeof synopsis === 'string' ? synopsis : article.synopsis,
    coverImageUrl: typeof coverImageUrl === 'string' ? coverImageUrl : article.coverImageUrl,
    updatedAt: now
  };

  await storage.updateArticle(updated);
  res.json(updated);
});

app.post('/articles/:id/purchase', async (req: Request, res: Response) => {
  const { userId } = req.body ?? {};

  if (!userId) {
    res.status(400).json({ message: 'userId is required' });
    return;
  }

  const article = await storage.getArticleById(req.params.id);

  if (!article) {
    res.status(404).json({ message: 'Article not found' });
    return;
  }

  const existing = await storage.findPurchase(userId, article.id);

  if (existing) {
    res.status(200).json(existing);
    return;
  }

  const purchase = {
    id: uuid(),
    articleId: article.id,
    userId,
    purchasedAt: new Date().toISOString(),
    priceCents: article.priceCents
  };

  await storage.recordPurchase(purchase);
  res.status(201).json(purchase);
});

app.listen(port, () => {
  // eslint-disable-next-line no-console
  console.log(`Server listening on port ${port}`);
});

