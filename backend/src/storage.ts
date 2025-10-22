import { promises as fs } from 'fs';
import path from 'path';
import { Article, DatabaseSchema, Purchase } from './types';

const DEFAULT_DATA: DatabaseSchema = {
  articles: [],
  purchases: []
};

export class JsonStorage {
  private filePath: string;
  private data: DatabaseSchema = DEFAULT_DATA;
  private isInitialized = false;

  constructor(filePath?: string) {
    this.filePath = filePath ?? path.join(process.cwd(), 'data.json');
  }

  private async ensureInitialized(): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    try {
      const raw = await fs.readFile(this.filePath, 'utf-8');
      this.data = JSON.parse(raw) as DatabaseSchema;
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
        await this.persist();
      } else {
        throw error;
      }
    }

    this.isInitialized = true;
  }

  private async persist(): Promise<void> {
    await fs.writeFile(this.filePath, JSON.stringify(this.data, null, 2), 'utf-8');
  }

  public async listArticles(): Promise<Article[]> {
    await this.ensureInitialized();
    return this.data.articles;
  }

  public async getArticleById(id: string): Promise<Article | undefined> {
    await this.ensureInitialized();
    return this.data.articles.find((article) => article.id === id);
  }

  public async createArticle(article: Article): Promise<Article> {
    await this.ensureInitialized();
    this.data.articles.push(article);
    await this.persist();
    return article;
  }

  public async updateArticle(updated: Article): Promise<Article> {
    await this.ensureInitialized();
    const index = this.data.articles.findIndex((article) => article.id === updated.id);

    if (index === -1) {
      throw new Error('Article not found');
    }

    this.data.articles[index] = updated;
    await this.persist();
    return updated;
  }

  public async recordPurchase(purchase: Purchase): Promise<Purchase> {
    await this.ensureInitialized();
    this.data.purchases.push(purchase);
    await this.persist();
    return purchase;
  }

  public async listPurchasesForUser(userId: string): Promise<Purchase[]> {
    await this.ensureInitialized();
    return this.data.purchases.filter((purchase) => purchase.userId === userId);
  }

  public async findPurchase(userId: string, articleId: string): Promise<Purchase | undefined> {
    await this.ensureInitialized();
    return this.data.purchases.find((purchase) => purchase.userId === userId && purchase.articleId === articleId);
  }
}
