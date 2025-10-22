export interface Article {
  id: string;
  title: string;
  author?: string;
  synopsis?: string;
  coverImageUrl?: string;
  content: string;
  priceCents: number;
  createdAt: string;
  updatedAt: string;
}

export interface Purchase {
  id: string;
  articleId: string;
  userId: string;
  purchasedAt: string;
  priceCents: number;
}

export interface DatabaseSchema {
  articles: Article[];
  purchases: Purchase[];
}
